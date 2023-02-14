# frozen_string_literal: true

require 'sorbet-runtime'
require 'concurrent-ruby'
require 'typhoeus'
require 'json'

module DevCycle
  class ConfigManager
    extend T::Sig

    sig { params(sdkKey: String, local_bucketing: LocalBucketing).returns(NilClass) }
    def initialize(sdkKey, local_bucketing)
      @first_load = true
      @local_bucketing = local_bucketing
      @sdkKey = sdkKey
      @config_e_tag = ""
      @config_poller = Concurrent::TimerTask.new(
        { execution_interval: @local_bucketing.options.config_polling_interval_ms / 1000, run_now: true }) do |task|
        fetch_config(false, task)
      end
      @config_poller.execute
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
      when 200..299
        @config_e_tag = resp.headers['Etag']
        return set_config(resp.body)
      when 403
        raise("Failed to download DevCycle config; Invalid SDK Key.")
      when 500...599
        if !retrying
          return fetch_config(true, task)
        end
        puts("Failed to download DevCycle config. Status: #{resp.code}")
      else
        task.shutdown
        raise("Unexpected response code - DevCycle Response: #{Oj.dump(resp)}")
      end
      nil
    end

    def set_config(config)
      if !JSON.parse(config).is_a?(Hash)
        raise("Invalid JSON body parsed from Config Response")
      end

      begin
        @local_bucketing.store_config(@sdkKey, config)
      rescue => error
        # TODO: Remove after we're done testing
        puts("Invalid config set")
        puts(error)
        exit(-1)
      end
      if @first_load
        puts("Config Set.")
      end
    end

    def get_config_url
      configBasePath = @local_bucketing.options.config_cdn_uri
      "#{configBasePath}/config/v1/server/#{@sdkKey}.json"
    end

    def close

    end

  end

end
