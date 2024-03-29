require 'sinatra'
require "sinatra/reloader" if development?
require 'devcycle-ruby-server-sdk'
require 'json'

set :port, 3000

sdk_key = ARGV[0]

if !sdk_key
  fail Exception, 'Must provide server SDK token'
end

DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = sdk_key
  config.enable_edge_db = false
end

options = DevCycle::Options.new(enable_cloud_bucketing: true)
api_instance = DevCycle::Client.new(sdk_key, options)
user = DevCycle::User.new({ user_id: 'my-user' })


get '/' do
  variable = api_instance.variable(user, "bool-var", false)
  puts "bool-var variable value is: #{variable.value}"
  puts "\n"

  variable_value = api_instance.variable_value(user, "string-var", "string-var-default")
  puts "string-var variable value is: #{variable_value}"

  all_variables = api_instance.all_variables(user)
  puts "all_variables result is:\n#{JSON.pretty_generate(all_variables.to_hash)}"
  puts "\n"

  all_features = api_instance.all_features(user)
  puts "all_features result is:\n#{JSON.pretty_generate(all_features.to_hash)}"
end

get '/track_event' do
  user = DevCycle::User.new({ user_id: 'my-user' })
  event_data = DevCycle::Event.new({
      type: "my-event",
      target: "some_event_target",
      value: 12,
      metaData: {
          myKey: "my-value"
      }
  })

  result = api_instance.track(user, event_data)
end
