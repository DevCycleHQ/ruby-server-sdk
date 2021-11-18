# DevCycle::ErrorResponse

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **message** | **String** | Error message |  |
| **data** | **Object** | Additional error information detailing the error reasoning | [optional] |

## Example

```ruby
require 'devcycle-server-sdk'

instance = DevCycle::ErrorResponse.new(
  message: null,
  data: null
)
```

