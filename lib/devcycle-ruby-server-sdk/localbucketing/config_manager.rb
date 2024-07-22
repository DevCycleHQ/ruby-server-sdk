# frozen_string_literal: true

require 'sorbet-runtime'
require 'concurrent-ruby'
require 'typhoeus'
require 'json'
require 'time'
require 'ld-eventsource'

module DevCycle
  class ConfigManager
    extend T::Sig
    sig { params(
      sdkKey: String,
      local_bucketing: LocalBucketing,
      wait_for_init: T::Boolean
    ).void }
    def initialize(sdkKey, local_bucketing, wait_for_init)
      @first_load = true
      @config_version = "v1"
      @local_bucketing = local_bucketing
      @sdkKey = sdkKey
      @sse_url = ""
      @config_e_tag = ""
      @config_last_modified = ""
      @logger = local_bucketing.options.logger
      @enable_sse = local_bucketing.options.enable_beta_realtime_updates
      @polling_enabled = true
      @sse_active = false
      @max_config_retries = 2
      @config_poller = Concurrent::TimerTask.new({
                                                   execution_interval: @local_bucketing.options.config_polling_interval_ms.fdiv(1000)
                                                 }) do |_|
        fetch_config
      end

      t = Thread.new { initialize_config }
      t.join if wait_for_init
    end

    def initialize_config
      begin
        fetch_config
        start_polling(false)
      rescue => e
        @logger.error("DevCycle: Error Initializing Config: #{e.message}")
      ensure
        @local_bucketing.initialized = true
      end
    end

    def fetch_config(min_last_modified: -1)
      return unless @polling_enabled || @sse_active && @enable_sse

      req = Typhoeus::Request.new(
        get_config_url,
        headers: {
          Accept: "application/json",
        })

      begin
        Date.parse(@config_last_modified)

        if @config_last_modified != ""
          if min_last_modified != -1
            parsed_sse_ts = Time.at(min_last_modified)
            if parsed_sse_ts.utc > @config_last_modified.utc
              req.options[:headers]["If-Modified-Since"] = parsed_sse_ts.utc.httpdate
            else
              req.options[:headers]["If-Modified-Since"] = Time.httpdate(@config_last_modified)
            end
          else
            req.options[:headers]["If-Modified-Since"] = Time.httpdate(@config_last_modified)
          end
        end
      rescue
      end

      if @config_e_tag != ""
        req.options[:headers]['If-None-Match'] = @config_e_tag
      end

      @max_config_retries.times do
        @logger.debug("Requesting new config from #{get_config_url}, current etag: #{@config_e_tag}, last modified: #{@config_last_modified}")
        resp = req.run
        @logger.debug("Config request complete, status: #{resp.code}")
        case resp.code
        when 304
          @logger.debug("Config not modified, using cache, etag: #{@config_e_tag}, last modified: #{@config_last_modified}")
          break
        when 200
          @logger.debug("New config received, etag: #{resp.headers['Etag']} LM:#{resp.headers['Last-Modified']}")
          lm_header = resp.headers['Last-Modified']
          begin
            if @config_last_modified == ""
              set_config(resp.body, resp.headers['Etag'], lm_header)
              return
            end

            lm_timestamp = Time.rfc2822(lm_header)
            current_lm = Time.rfc2822(@config_last_modified)
            if lm_timestamp == "" && @config_last_modified == "" || (current_lm.utc < lm_timestamp.utc)
              set_config(resp.body, resp.headers['Etag'], lm_header)
              @logger.debug("New config stored, etag: #{@config_e_tag}, last modified: #{lm_header}")
            else
              @logger.warn("Config response was an older config than currently stored config.")
            end
          rescue
            @logger.warn("Failed to parse last modified header, setting config.")
            set_config(resp.body, resp.headers['Etag'], lm_header)
          end
          break
        when 403
          stop_polling
          stop_sse
          @logger.error("Failed to download DevCycle config; Invalid SDK Key.")
          break
        when 404
          stop_polling
          stop_sse
          @logger.error("Failed to download DevCycle config; Config not found.")
          break
        when 500...599
          @logger.error("Failed to download DevCycle config. Status: #{resp.code}")
        else
          @logger.error("Unexpected response from DevCycle CDN")
          @logger.error("Response code: #{resp.code}")
          @logger.error("Response body: #{resp.body}")
          break
        end
      end
      nil
    end

    def set_config(config, etag, lastmodified)
      if !JSON.parse(config).is_a?(Hash)
        raise("Invalid JSON body parsed from Config Response")
      end
      parsed_config = JSON.parse(config)

      if parsed_config['sse'] != nil
        raw_url = "#{parsed_config['sse']['hostname']}#{parsed_config['sse']['path']}"
        if @sse_url != raw_url && raw_url != ""
          @sse_url = raw_url
          stop_sse
          init_sse(@sse_url)
        end
      end
      @local_bucketing.store_config(config)
      @config_e_tag = etag
      @config_last_modified = lastmodified
      @local_bucketing.has_config = true
    end

    def get_config_url
      configBasePath = @local_bucketing.options.config_cdn_uri
      "#{configBasePath}/config/#{@config_version}/server/#{@sdkKey}.json"
    end

    def start_polling(sse)
      if sse
        @config_poller.shutdown if @config_poller.running?
        @config_poller = Concurrent::TimerTask.new({ execution_interval: 60 *10 }) do |_|
          fetch_config
        end
      end
      @polling_enabled = true
      @config_poller.execute if @polling_enabled && (!@sse_active || sse)
    end

    def stop_polling()
      @polling_enabled = false
      @config_poller.shutdown if @config_poller.running?
    end

    def stop_sse
      return unless @enable_sse
      @polling_enabled = true
      @sse_active = false
      @sse_client.close if @sse_client
      start_polling(false)
    end

    def close
      @config_poller.shutdown if @config_poller.running?
      nil
    end

    def init_sse(path)
      return unless @enable_sse
      @logger.debug("Initializing SSE with url: #{path}")
      @sse_active = true
      @sse_client = SSE::Client.new(path) do |client|
        client.on_event do |event|
          parsed_json = JSON.parse(event.data)
          handle_sse(parsed_json)
        end
        client.on_error do |error|
          @logger.debug("SSE Error: #{error.message}")
        end
      end
      stop_polling
      start_polling(true)
    end

    def handle_sse(eventData)
      if eventData["data"] == nil
        return
      end
      @logger.debug("SSE Message received: #{eventData["data"]}")
      parsed_event_data = JSON.parse(eventData["data"])

      last_modified = parsed_event_data["lastModified"]
      event_type = parsed_event_data["type"]

      if event_type == "refetchConfig" || event_type == nil
        @logger.debug("Re-fetching new config with TS: #{last_modified}")
        fetch_config(min_last_modified: last_modified / 1000)
      end
    end
  end
end
