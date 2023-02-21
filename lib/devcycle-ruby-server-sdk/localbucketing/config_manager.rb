# frozen_string_literal: true

require 'sorbet-runtime'
require 'concurrent-ruby'
require 'typhoeus'
require 'json'

module DevCycle
  class ConfigManager
    extend T::Sig


    sig { params(sdkKey: String, local_bucketing: LocalBucketing, initialize_callback: T.nilable(T.proc.params(error: String).returns(NilClass))).returns(NilClass) }
    def initialize(sdkKey, local_bucketing, initialize_callback)
      @first_load = true
      @config_version = "v1"
      @local_bucketing = local_bucketing
      @sdkKey = sdkKey
      @config_e_tag = ""
      @logger = local_bucketing.options.logger
      @initialize_callback = initialize_callback

      @config_poller = Concurrent::TimerTask.new(
        {
          execution_interval: @local_bucketing.options.config_polling_interval_ms.fdiv(1000),
          run_now: true
        }) do |task|
        fetch_config(false, task)
      end

      Thread.start { fetch_config(false, nil) }
      nil
    end

    def fetch_config(retrying, task)
      req = Typhoeus::Request.new(
        get_config_url,
        headers: {
          Accept: "application/json",
        })

      if @config_e_tag != ""
        req.headers['If-None-Match'] = @config_e_tag
      end

      resp = req.run

      case resp.code
      when 304
        return nil
      when 200
        return set_config(resp.body, resp.headers['Etag'])
      when 403
        raise("Failed to download DevCycle config; Invalid SDK Key.")
      when 500...599
        if !retrying
          return fetch_config(true, task)
        end
        @logger.warn("Failed to download DevCycle config. Status: #{resp.code}")
      else
        if task != nil
          task.shutdown
        end
        raise("Unexpected response code - DevCycle Response: #{Oj.dump(resp)}")
      end

      nil
    end

    def set_config(config, etag)
      if !JSON.parse(config).is_a?(Hash)
        raise("Invalid JSON body parsed from Config Response")
      end

      error = nil
      begin
        @local_bucketing.store_config(@sdkKey, config)
      rescue => e
        # TODO: Remove after we're done testing
        @logger.error("Invalid config set")
        @logger.error(e)
        error = e.to_s
      end

      @config_e_tag = etag

      if @first_load
        @logger.info("Config Set. Client Initialized.")
        @first_load = false
        @local_bucketing.initialized = true
        @config_poller.execute
        @initialize_callback.call(error) if @initialize_callback != nil
      end
    end

    def get_config_url
      configBasePath = @local_bucketing.options.config_cdn_uri
      "#{configBasePath}/config/#{@config_version}/server/#{@sdkKey}.json"
    end

    # TODO: Add a close method
    def close
    end
  end
end
