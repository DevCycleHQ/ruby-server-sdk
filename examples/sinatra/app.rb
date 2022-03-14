require 'sinatra'
require "sinatra/reloader" if development?
require 'devcycle-ruby-server-sdk'

token = ARGV[0]

if !token
    fail Exception, 'Must provide server SDK token'
end

DevCycle.configure do |config|
    # Configure API key authorization: bearerAuth
    config.api_key['bearerAuth'] = token
    # config.debugging = true
end

api_instance = DevCycle::DVCClient.new
user_data = DevCycle::UserData.new({
    user_id: 'my-user',
    app_version: '1.2.3'
})

get '/' do
  'Hello world!'
end

get '/experiment' do
    result = api_instance.variable(user_data, "test-feature", false)
    p result

    "Your variable result is: #{result.value}"
end

get '/track-event' do
    event_data = DevCycle::Event.new({
        type: "my-event",
        target: "some_event_target",
        value: 12,
        meta_data: {
            myKey: "my-value"
        }
    })

    result = api_instance.track(user_data, event_data)

    p result
end
