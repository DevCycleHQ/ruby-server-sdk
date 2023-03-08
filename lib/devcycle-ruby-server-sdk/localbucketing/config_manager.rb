# frozen_string_literal: true

require 'sorbet-runtime'
require 'concurrent-ruby'
require 'typhoeus'
require 'json'

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
        @logger.error("DVC Error Initializing Config: #{e.message}")
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

      if @config_e_tag != ""
        req.options[:headers]['If-None-Match'] = @config_e_tag
      end

      @max_config_retries.times do
        resp = req.run
        case resp.code
        when 304
          @logger.debug("Config not modified, using cache, etag: #{this.configEtag}")
          return
        when 200
          set_config(resp.body, resp.headers['Etag'])
          return
        when 403
          stop_polling
          @logger.error("Failed to download DevCycle config; Invalid SDK Key.")
          return
        when 500...599
          @logger.error("Failed to download DevCycle config. Status: #{resp.code}")
        else
          stop_polling
          @logger.error("Unexpected response code - DevCycle Response: #{Oj.dump(resp)}")
          return
        end
      end

      nil
    end

    def set_config(config, etag)
      if !JSON.parse(config).is_a?(Hash)
        raise("Invalid JSON body parsed from Config Response")
      end

      @local_bucketing.store_config(config)
      @config_e_tag = etag
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
