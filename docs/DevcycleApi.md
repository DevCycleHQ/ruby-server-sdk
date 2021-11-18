# DevCycle::DevcycleApi

All URIs are relative to *https://bucketing-api.devcycle.com*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**get_features**](DevcycleApi.md#get_features) | **POST** /v1/features | Get all features by key for user data |
| [**get_variable_by_key**](DevcycleApi.md#get_variable_by_key) | **POST** /v1/variables/{key} | Get variable by key for user data |
| [**get_variables**](DevcycleApi.md#get_variables) | **POST** /v1/variables | Get all variables by key for user data |
| [**post_events**](DevcycleApi.md#post_events) | **POST** /v1/track | Post events to DevCycle for user |


## get_features

> <Hash<String, Feature>> get_features(user_data)

Get all features by key for user data

### Examples

```ruby
require 'time'
require 'devcycle-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
user_data = DevCycle::UserData.new({user_id: 'user_id_example'}) # UserData | 

begin
  # Get all features by key for user data
  result = api_instance.get_features(user_data)
  p result
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->get_features: #{e}"
end
```

#### Using the get_features_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Hash<String, Feature>>, Integer, Hash)> get_features_with_http_info(user_data)

```ruby
begin
  # Get all features by key for user data
  data, status_code, headers = api_instance.get_features_with_http_info(user_data)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <Hash<String, Feature>>
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->get_features_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **user_data** | [**UserData**](UserData.md) |  |  |

### Return type

[**Hash&lt;String, Feature&gt;**](Feature.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## get_variable_by_key

> <Variable> get_variable_by_key(key, user_data)

Get variable by key for user data

### Examples

```ruby
require 'time'
require 'devcycle-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
key = 'key_example' # String | Variable key
user_data = DevCycle::UserData.new({user_id: 'user_id_example'}) # UserData | 

begin
  # Get variable by key for user data
  result = api_instance.get_variable_by_key(key, user_data)
  p result
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->get_variable_by_key: #{e}"
end
```

#### Using the get_variable_by_key_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Variable>, Integer, Hash)> get_variable_by_key_with_http_info(key, user_data)

```ruby
begin
  # Get variable by key for user data
  data, status_code, headers = api_instance.get_variable_by_key_with_http_info(key, user_data)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <Variable>
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->get_variable_by_key_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **key** | **String** | Variable key |  |
| **user_data** | [**UserData**](UserData.md) |  |  |

### Return type

[**Variable**](Variable.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## get_variables

> <Hash<String, Variable>> get_variables(user_data)

Get all variables by key for user data

### Examples

```ruby
require 'time'
require 'devcycle-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
user_data = DevCycle::UserData.new({user_id: 'user_id_example'}) # UserData | 

begin
  # Get all variables by key for user data
  result = api_instance.get_variables(user_data)
  p result
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->get_variables: #{e}"
end
```

#### Using the get_variables_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Hash<String, Variable>>, Integer, Hash)> get_variables_with_http_info(user_data)

```ruby
begin
  # Get all variables by key for user data
  data, status_code, headers = api_instance.get_variables_with_http_info(user_data)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <Hash<String, Variable>>
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->get_variables_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **user_data** | [**UserData**](UserData.md) |  |  |

### Return type

[**Hash&lt;String, Variable&gt;**](Variable.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## post_events

> <InlineResponse201> post_events(user_data_and_events_body)

Post events to DevCycle for user

### Examples

```ruby
require 'time'
require 'devcycle-server-sdk'
# setup authorization
DevCycle.configure do |config|
  # Configure API key authorization: bearerAuth
  config.api_key['bearerAuth'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['bearerAuth'] = 'Bearer'
end

api_instance = DevCycle::DevcycleApi.new
user_data_and_events_body = DevCycle::UserDataAndEventsBody.new # UserDataAndEventsBody | 

begin
  # Post events to DevCycle for user
  result = api_instance.post_events(user_data_and_events_body)
  p result
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->post_events: #{e}"
end
```

#### Using the post_events_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<InlineResponse201>, Integer, Hash)> post_events_with_http_info(user_data_and_events_body)

```ruby
begin
  # Post events to DevCycle for user
  data, status_code, headers = api_instance.post_events_with_http_info(user_data_and_events_body)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <InlineResponse201>
rescue DevCycle::ApiError => e
  puts "Error when calling DevcycleApi->post_events_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **user_data_and_events_body** | [**UserDataAndEventsBody**](UserDataAndEventsBody.md) |  |  |

### Return type

[**InlineResponse201**](InlineResponse201.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

