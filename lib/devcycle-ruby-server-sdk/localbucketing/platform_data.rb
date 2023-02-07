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
      self.new('server', '1.0.0', RUBY_VERSION, nil, 'Ruby', Socket.gethostname)
    end
  end
end