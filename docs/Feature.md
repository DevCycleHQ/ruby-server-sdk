# DevCycle::Feature

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **_id** | **String** | unique database id |  |
| **key** | **String** | Unique key by Project, can be used in the SDK / API to reference by &#39;key&#39; rather than _id. |  |
| **type** | **String** | Feature type |  |
| **_variation** | **String** | Bucketed feature variation |  |
| **eval_reason** | **String** | Evaluation reasoning | [optional] |

## Example

```ruby
require 'devcycle-server-sdk'

instance = DevCycle::Feature.new(
  _id: null,
  key: null,
  type: null,
  _variation: null,
  eval_reason: null
)
```

