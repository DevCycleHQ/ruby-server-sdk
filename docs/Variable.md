# DevCycle::Variable

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **_id** | **String** | unique database id |  |
| **key** | **String** | Unique key by Project, can be used in the SDK / API to reference by &#39;key&#39; rather than _id. |  |
| **type** | **String** | Variable type |  |
| **value** | **Object** | Variable value can be a string, number, boolean, or JSON |  |

## Example

```ruby
require 'devcycle-server-sdk'

instance = DevCycle::Variable.new(
  _id: null,
  key: null,
  type: null,
  value: null
)
```

