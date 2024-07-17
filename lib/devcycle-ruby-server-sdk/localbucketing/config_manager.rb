# frozen_string_literal: true

require 'sorbet-runtime'
require 'concurrent-ruby'
require 'typhoeus'
require 'json'
require 'time'

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
      @config_e_tag = ""
      @config_last_modified = ""
      @logger = local_bucketing.options.logger
      @polling_enabled = true
      @max_config_retries = 2

      @config_poller = Concurrent::TimerTask.new({
                                                   execution_interval: @local_bucketing.options.config_polling_interval_ms.fdiv(1000)
                                                 }) do |task|
        fetch_config
      end

      t = Thread.new { initialize_config }
      t.join if wait_for_init
    end

    def initialize_config
      begin
        fetch_config
        @config_poller.execute if @polling_enabled
      rescue => e
        @logger.error("DevCycle: Error Initializing Config: #{e.message}")
      ensure
        @local_bucketing.initialized = true
      end
    end

    def fetch_config
      return unless @polling_enabled

      req = Typhoeus::Request.new(
        get_config_url,
        headers: {
          Accept: "application/json",
        })

      begin
        Date.parse(@config_last_modified)
        if @config_last_modified != ""
          req.options[:headers]["If-Modified-Since"] = Time.httpdate(@config_last_modified)
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
          @logger.error("Failed to download DevCycle config; Invalid SDK Key.")
          break
        when 404
          stop_polling
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

      @local_bucketing.store_config(config)
      @config_e_tag = etag
      @config_last_modified = lastmodified
      @local_bucketing.has_config = true
    end

    def get_config_url
      configBasePath = @local_bucketing.options.config_cdn_uri
      "#{configBasePath}/config/#{@config_version}/server/#{@sdkKey}.json"
    end

    def stop_polling
      @polling_enabled = false
      @config_poller.shutdown if @config_poller.running?
    end

    def close
      @config_poller.shutdown if @config_poller.running?
      nil
    end
  end
end
