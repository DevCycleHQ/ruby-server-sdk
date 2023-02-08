# frozen_string_literal: true
require 'socket'
require 'json'

module DevCycle
  class PlatformData
    attr_accessor :deviceModel, :platformVersion, :sdkVersion, :sdkType, :platform, :hostname

    def initialize(sdk_type, sdk_version, platform_version, device_model, platform, hostname)
      @sdkType = sdk_type
      @sdkVersion = sdk_version
      @platformVersion = platform_version
      @deviceModel = device_model
      @platform = platform
      @hostname = hostname
    end
    def default
      @sdkType='server'
      @sdkVersion = '1.0.0'
      @platformVersion = RUBY_VERSION
      @deviceModel = nil
      @platform = 'Ruby'
      @hostname = Socket.gethostname
      self
    end
  end
end