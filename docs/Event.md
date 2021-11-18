# DevCycle::Event

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **type** | **String** | Custom event type |  |
| **target** | **String** | Custom event target / subject of event. Contextual to event type | [optional] |
| **date** | **Float** | Unix epoch time the event occurred according to client | [optional] |
| **value** | **Float** | Value for numerical events. Contextual to event type | [optional] |
| **meta_data** | **Object** | Extra JSON metadata for event. Contextual to event type | [optional] |

## Example

```ruby
require 'devcycle-server-sdk'

instance = DevCycle::Event.new(
  type: null,
  target: null,
  date: null,
  value: null,
  meta_data: null
)
```

