# DevCycle::UserDataAndEventsBody

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **events** | [**Array&lt;Event&gt;**](Event.md) |  | [optional] |
| **user** | [**UserData**](UserData.md) |  | [optional] |

## Example

```ruby
require 'devcycle-server-sdk'

instance = DevCycle::UserDataAndEventsBody.new(
  events: null,
  user: null
)
```

