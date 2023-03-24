require 'devcycle-ruby-server-sdk'

options = DevCycle::DVCOptions.new(enable_cloud_bucketing: false, event_flush_interval_ms: 1000, config_polling_interval_ms: 1000)
test_user = DevCycle::UserData.new({ user_id: "test" })
test_event = DevCycle::Event.new({
                                   :'type' => :'randomEval',
                                   :'target' => :'custom target'
                                 })
dvc_client = DevCycle::DVCClient.new("dvc_server_token_hash", options, true)
puts dvc_client.variable(test_user, 'test', false)
puts dvc_client.all_variables(test_user)
puts dvc_client.all_features(test_user)
dvc_client.track(test_user, test_event)

puts(dvc_client.close)
sleep 10
# test_event = DevCycle::Event.new({
#                                     :'type' => :'randomEval',
#                                     :'target' => :'custom target'
#                                   })
# bucketed_config = localbucketing.generate_bucketed_config(test_user)
# puts(bucketed_config.variable_variation_map)
# puts(Oj.dump(bucketed_config))
# puts(bucketed_config.project)

# begin
#   localbucketing.queue_event(test_user, test_event)
# rescue
#   puts("Caught exception that doesn't exist.")
# end

# puts("event queue size")
# puts(localbucketing.check_event_queue_size)
# puts("flush events")
# flushed = localbucketing.flush_event_queue
# puts(localbucketing.check_event_queue_size)
# puts("queue new event")
# localbucketing.queue_event(test_user, test_event)
# puts("size")
# puts(localbucketing.check_event_queue_size)
# puts("fail-flush - retry")
# flushed = localbucketing.flush_event_queue
# localbucketing.on_payload_failure(flushed.payloadId, true)
# puts("queue size")
# puts(localbucketing.check_event_queue_size)
# puts("fail-flush - fail")
# flushed = localbucketing.flush_event_queue
# localbucketing.on_payload_failure(flushed.payloadId, false)
# puts("queue size")
# puts(localbucketing.check_event_queue_size)

# puts("queue agg event")
# puts(localbucketing.queue_aggregate_event(test_event, bucketed_config))
# puts("event size")
# puts(localbucketing.check_event_queue_size)
