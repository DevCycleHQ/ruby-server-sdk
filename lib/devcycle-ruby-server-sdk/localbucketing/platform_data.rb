# frozen_string_literal: true

require 'socket'
require 'oj'

module DevCycle
  class PlatformData
    attr_accessor :deviceModel, :platformVersion, :sdkVersion, :sdkType, :platform, :hostname

    def initialize(sdk_type = nil, sdk_version = nil, platform_version = nil, device_model = nil, platform = nil, hostname = nil)
      @sdkType = sdk_type
      @sdkVersion = sdk_version
      @platformVersion = platform_version
      @deviceModel = device_model
      @platform = platform
      @hostname = hostname
    end

    def default
      @sdkType = 'server'
      @sdkVersion = VERSION
      @platformVersion = RUBY_VERSION
      @deviceModel = nil
      @platform = 'Ruby'
      @hostname = Socket.gethostname
      self
    end

    def to_hash
      {
        sdkType: @sdkType,
        sdkVersion: @sdkVersion,
        platformVersion: @platformVersion,
        deviceModel: @deviceModel,
        platform: @platform,
        hostname: @hostname
      }
    end

    def to_json
      Oj.dump(to_hash, mode: :json)
    end
  end
end