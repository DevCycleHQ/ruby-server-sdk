require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'webmock'
include WebMock::API

if ENV['MOCK_CONFIG'] == 'true'
  ENV['DEVCYCLE_SERVER_SDK_KEY'] = 'dvc_server_token_hash'
  WebMock.enable!
  WebMock.disable_net_connect!

  config_path = File.expand_path('../test_data/large_config.json', __dir__)
  stub_request(:get, "https://config-cdn.devcycle.com/config/v2/server/#{ENV['DEVCYCLE_SERVER_SDK_KEY']}.json").
    to_return(headers: { 'Etag': 'test' }, body: File.new(config_path).read, status: 200)

  stub_request(:post, 'https://events.devcycle.com/v1/events/batch').
    to_return(status: 201, body: '{}')
end

module LocalBucketingExample
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
