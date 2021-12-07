# DevCycle Ruby SDK

Welcome to the the DevCycle Ruby SDK, initially generated via the [DevCycle Bucketing API](https://docs.devcycle.com/bucketing-api/#tag/devcycle).

## Installation

Install the gem

`gem install devcycle-ruby-server-sdk`
  

## Getting Started

Please follow the [installation](#installation) procedure and then run the following code:

```ruby
# Load the gem
require 'devcycle-server-sdk'

# Setup authorization
DevCycle.configure do |config|
  # Configure API key authorization
  config.api_key['bearerAuth'] = 'YOUR API KEY'
end

api_instance = DevCycle::DVCClient.new
user_data = DevCycle::UserData.new({user_id: 'user_id_example'}) # UserData | 

begin
  #Get all features for user data
  result = api_instance.all_features(user_data)
  p result
rescue DevCycle::ApiError => e
  puts "Exception when calling DVCClient->all_features: #{e}"
end

```

## Usage

### Configure SDK
```ruby
# Load the gem
require 'devcycle-server-sdk'

# Setup authorization
DevCycle.configure do |config|
  # Configure API key authorization
  config.api_key['bearerAuth'] = 'YOUR API KEY'
end

api_instance = DevCycle::DVCClient.new
user_data = DevCycle::UserData.new({user_id: 'user_id_example'}) # UserData | 
```

### Get all Features
```ruby
begin
  #Get all features for user data
  result = api_instance.all_features(user_data)
  p result
rescue DevCycle::ApiError => e
  puts "Exception when calling DVCClient->all_features: #{e}"
end
```

### Get Variable by key
```ruby
begin
  # Get value of given variable by key, using default value if segmentation is not passed or variable does not exit
  result = api_instance.variable("variable-key", user_data, true)
  p "Received value for #{result.key}: #{result.value}"
rescue DevCycle::ApiError => e
  puts "Exception when calling DVCClient->variable: #{e}"
end
```

### Get all Variables
```ruby
begin
  #Get all variables for user data
  result = api_instance.all_variables(user_data)
  p result
rescue DevCycle::ApiError => e
  puts "Exception when calling DVCClient->all_variables: #{e}"
end
```

### Track Event
```ruby

event_data = DevCycle::Event.new({
  type: "my-event",
  target: "some_event_target",
  value: 12,
  meta_data: {
    myKey: "my-value"
  }
})

begin
  # Post events for given user data
  result = api_instance.track(user_data, event_data)
  p result
rescue DevCycle::ApiError => e
  puts "Exception when calling DVCClient->track: #{e}"
end
```

### Override Logger
To provide a custom logger, override the `logger` property of the SDK configuration.
```ruby
DevCycle.configure do |config|
  # Configure API key authorization
  config.api_key['bearerAuth'] = 'YOUR API KEY'

  # Override the default logger
  config.logger = MyLogger
end
```

### Troubleshooting
To see a detailed log of the requests being made to the DevCycle API, enable SDK debug logging:
```ruby
DevCycle.configure do |config|
  # Configure API key authorization
  config.api_key['bearerAuth'] = 'YOUR API KEY'

  # Enable detailed debug logs of requests being sent to the DevCycle API
  config.debugging = true
end
```


## Documentation for Models

 - [DevCycle::ErrorResponse](docs/ErrorResponse.md)
 - [DevCycle::Event](docs/Event.md)
 - [DevCycle::Feature](docs/Feature.md)
 - [DevCycle::UserData](docs/UserData.md)
 - [DevCycle::Variable](docs/Variable.md)

### Development

To build the Ruby code into a gem:

```shell
gem build devcycle-ruby-server-sdk.gemspec
```

Then either install the gem locally:

```shell
gem install ./devcycle-ruby-server-sdk-1.0.0.gem
```

(for development, run `gem install --dev ./devcycle-ruby-server-sdk-1.0.0.gem` to install the development dependencies)

or publish the gem to a gem hosting service, e.g. [RubyGems](https://rubygems.org/).

Finally add this to the Gemfile:

    gem 'ruby-server-sdk', '~> 1.0.0'
