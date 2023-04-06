=begin
#DevCycle Bucketing API

#Documents the DevCycle Bucketing API which provides and API interface to User Bucketing and for generated SDKs.

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
OpenAPI Generator version: 5.3.0

=end

# Common files
require 'devcycle-ruby-server-sdk/api_client'
require 'devcycle-ruby-server-sdk/api_error'
require 'devcycle-ruby-server-sdk/version'
require 'devcycle-ruby-server-sdk/configuration'

# Models
require 'devcycle-ruby-server-sdk/models/error_response'
require 'devcycle-ruby-server-sdk/models/event'
require 'devcycle-ruby-server-sdk/models/feature'
require 'devcycle-ruby-server-sdk/models/inline_response201'
require 'devcycle-ruby-server-sdk/models/user_data'
require 'devcycle-ruby-server-sdk/models/user_data_and_events_body'
require 'devcycle-ruby-server-sdk/models/variable'

# APIs
require 'devcycle-ruby-server-sdk/api/devcycle_api'

require 'devcycle-ruby-server-sdk/localbucketing/dvc_options'
require 'devcycle-ruby-server-sdk/localbucketing/local_bucketing'
require 'devcycle-ruby-server-sdk/localbucketing/platform_data'
require 'devcycle-ruby-server-sdk/localbucketing/bucketed_user_config'
require 'devcycle-ruby-server-sdk/localbucketing/event_queue'
require 'devcycle-ruby-server-sdk/localbucketing/event_types'
require 'devcycle-ruby-server-sdk/localbucketing/proto/variableForUserParams_pb'
require 'devcycle-ruby-server-sdk/localbucketing/proto/helpers'

module DevCycle
  class << self
    # Customize default settings for the SDK using block.
    #   DevCycle.configure do |config|
    #     config.username = "xxx"
    #     config.password = "xxx"
    #   end
    # If no block given, return the default Configuration object.
    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end
  end
end
