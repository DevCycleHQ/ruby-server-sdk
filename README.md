# DevCycle Ruby Server SDK

Welcome to the the DevCycle Ruby SDK, initially generated via the [DevCycle Bucketing API](https://docs.devcycle.com/bucketing-api/#tag/devcycle).

## Installation

Install the gem

`gem install devcycle-ruby-server-sdk`
  

## Getting Started

Please follow the [installation](#installation) procedure and then run the following code:

```ruby
# Load the gem
require 'devcycle-ruby-server-sdk'

# Setup authorization
DevCycle.configure do |config|
  # Configure API key authorization
  config.api_key['bearerAuth'] = 'YOUR API KEY'
end

api_instance = DevCycle::Client.new
user = DevCycle::User.new({ user_id: 'user_id_example' }) # User | 

begin
  #Get all features for user data
  result = api_instance.all_features(user)
  p result
rescue DevCycle::ApiError => e
  puts "Exception when calling DevCycle::Client->all_features: #{e}"
end

```

## Usage

To find usage documentation, visit our [docs](https://docs.devcycle.com/docs/sdk/server-side-sdks/ruby#usage).