# DevCycle::Client

All URIs are relative to *https://bucketing-api.devcycle.com*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**all_features**](Client.md#all_features) | **POST** /v1/features | Get all features by key for user data |
| [**variable**](Client.md#variable) | **POST** /v1/variables/{key} | Get variable by key for user data |
| [**all_variables**](Client.md#all_variables) | **POST** /v1/variables | Get all variables by key for user data |
| [**track**](Client.md#track) | **POST** /v1/track | Post events to DevCycle for user |


## all_features

> <Hash<String, Feature>> all_features(user)

Get all features by key for user data

### Examples

```ruby
require 'time'
require 'devcycle-ruby-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
user = DevCycle::User.new({ user_id: 'user_id_example' }) # DevCycle::User | 

begin
  # Get all features by key for user data
  result = api_instance.all_features(user)
  p result
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->all_features: #{e}"
end
```

#### Using the all_features_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Hash<String, Feature>>, Integer, Hash)> all_features_with_http_info(user)

```ruby
begin
  # Get all features by key for user data
  data, status_code, headers = api_instance.all_features_with_http_info(user)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <Hash<String, Feature>>
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->all_features_with_http_info: #{e}"
end
```

### Parameters

| Name | Type                                  | Description | Notes |
| ---- |---------------------------------------| ----------- | ----- |
| **user** | [**DevCycle::User**](DevCycleUser.md) |  |  |

### Return type

[**Hash&lt;String, Feature&gt;**](Feature.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## variable_value

> variable_value(user, key)

Get variable value by key for user data

### Examples

```ruby
require 'time'
require 'devcycle-ruby-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
key = 'key_example' # String | Variable key
user = DevCycle::User.new({ user_id: 'user_id_example' }) # DevCycle::User | 

begin
  # Get variable by key for user data
  value = api_instance.variable_value(user, key)
  p value
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->variable: #{e}"
end
```

## variable

> <Variable> variable(user, key)

Get variable object by key for user data

### Examples

```ruby
require 'time'
require 'devcycle-ruby-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
key = 'key_example' # String | Variable key
user = DevCycle::User.new({ user_id: 'user_id_example' }) # DevCycle::User | 

begin
  # Get variable by key for user data
  result = api_instance.variable(user, key)
  p result
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->variable: #{e}"
end
```

#### Using the variable_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Variable>, Integer, Hash)> variable_with_http_info(key, user)

```ruby
begin
  # Get variable by key for user data
  data, status_code, headers = api_instance.variable_with_http_info(key, user)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <Variable>
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->variable_with_http_info: #{e}"
end
```

### Parameters

| Name | Type                                  | Description | Notes |
| ---- |---------------------------------------| ----------- | ----- |
| **key** | **String**                            | Variable key |  |
| **user** | [**DevCycle::User**](DevCycleUser.md) |  |  |

### Return type

[**Variable**](Variable.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## all_variables

> <Hash<String, Variable>> all_variables(user)

Get all variables by key for user data

### Examples

```ruby
require 'time'
require 'devcycle-ruby-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
user = DevCycle::User.new({ user_id: 'user_id_example' }) # User | 

begin
  # Get all variables by key for user data
  result = api_instance.all_variables(user)
  p result
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->all_variables: #{e}"
end
```

#### Using the all_variables_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Hash<String, Variable>>, Integer, Hash)> all_variables_with_http_info(user)

```ruby
begin
  # Get all variables by key for user data
  data, status_code, headers = api_instance.all_variables_with_http_info(user)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <Hash<String, Variable>>
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->all_variables_with_http_info: #{e}"
end
```

### Parameters

| Name | Type                                  | Description | Notes |
| ---- |---------------------------------------| ----------- | ----- |
| **user** | [**DevCycle::User**](DevCycleUser.md) |  |  |

### Return type

[**Hash&lt;String, Variable&gt;**](Variable.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## track

> <InlineResponse201> track(user, event_data)

Post events to DevCycle for user

### Examples

```ruby
require 'time'
require 'devcycle-ruby-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
user = DevCycle::User.new # DevCycle::User | 
event_data = DevCycle::Event.new # Event | 

begin
  # Post events to DevCycle for user
  result = api_instance.track(user, event_data)
  p result
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->track: #{e}"
end
```

#### Using the track_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<InlineResponse201>, Integer, Hash)> track_with_http_info(user_and_events_body)

```ruby
begin
  # Post events to DevCycle for user
  data, status_code, headers = api_instance.track_with_http_info(user_and_events_body)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <InlineResponse201>
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->track_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **user_and_events_body** | [**UserDataAndEventsBody**](UserDataAndEventsBody.md) |  |  |

### Return type

[**InlineResponse201**](InlineResponse201.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

