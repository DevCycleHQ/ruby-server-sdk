# DevCycle::UserData

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **user_id** | **String** | Unique id to identify the user |  |
| **email** | **String** | User&#39;s email used to identify the user on the dashboard / target audiences | [optional] |
| **name** | **String** | User&#39;s name used to identify the user on the dashboard / target audiences | [optional] |
| **language** | **String** | User&#39;s language in ISO 639-1 format | [optional] |
| **country** | **String** | User&#39;s country in ISO 3166 alpha-2 format | [optional] |
| **app_version** | **String** | App Version of the running application | [optional] |
| **app_build** | **String** | App Build number of the running application | [optional] |
| **custom_data** | **Object** | User&#39;s custom data to target the user with, data will be logged to DevCycle for use in dashboard. | [optional] |
| **private_custom_data** | **Object** | User&#39;s custom data to target the user with, data will not be logged to DevCycle only used for feature bucketing. | [optional] |
| **created_date** | **Float** | Date the user was created, Unix epoch timestamp format | [optional] |
| **last_seen_date** | **Float** | Date the user was created, Unix epoch timestamp format | [optional] |
| **platform** | **String** | Platform the Client SDK is running on | [optional] |
| **platform_version** | **String** | Version of the platform the Client SDK is running on | [optional] |
| **device_model** | **String** | User&#39;s device model | [optional] |
| **sdk_type** | **String** | DevCycle SDK type | [optional] |
| **sdk_version** | **String** | DevCycle SDK Version | [optional] |

## Example

```ruby
require 'devcycle-ruby-server-sdk'

instance = DevCycle::UserData.new(
  user_id: null,
  email: null,
  name: null,
  language: null,
  country: null,
  app_version: null,
  app_build: null,
  custom_data: null,
  private_custom_data: null,
  created_date: null,
  last_seen_date: null,
  platform: null,
  platform_version: null,
  device_model: null,
  sdk_type: null,
  sdk_version: null
)
```

