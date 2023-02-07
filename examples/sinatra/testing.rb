require 'devcycle-ruby-server-sdk'
require 'oj'
require 'socket'

localbucketing = DevCycle::LocalBucketing.new("dvc_server_token_hash", DevCycle::DVCOptions.new)

puts("config?")
localbucketing.store_config("dvc_server_token_hash", '{"project":{"settings":{"edgeDB":{"enabled":false},"optIn":{"enabled":true,"title":"Beta Feature Access","description":"Get early access to new features below","imageURL":"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR68cgQT_BTgnhWTdfjUXSN8zM9Vpxgq82dhw&usqp=CAU","colors":{"primary":"#0042f9","secondary":"#facc15"}}},"a0_organization":"org_NszUFyWBFy7cr95J","_id":"6216420c2ea68943c8833c09","key":"default"},"environment":{"_id":"6216420c2ea68943c8833c0b","key":"development"},"features":[{"_id":"6216422850294da359385e8b","key":"test","type":"release","variations":[{"variables":[{"_var":"6216422850294da359385e8d","value":true}],"name":"Variation On","key":"variation-on","_id":"6216422850294da359385e8f"},{"variables":[{"_var":"6216422850294da359385e8d","value":false}],"name":"Variation Off","key":"variation-off","_id":"6216422850294da359385e90"}],"configuration":{"_id":"621642332ea68943c8833c4a","targets":[{"distribution":[{"percentage":0.5,"_variation":"6216422850294da359385e8f"},{"percentage":0.5,"_variation":"6216422850294da359385e90"}],"_audience":{"_id":"621642332ea68943c8833c4b","filters":{"operator":"and","filters":[{"values":[],"type":"all","filters":[]}]}},"_id":"621642332ea68943c8833c4d"}],"forcedUsers":{}}}],"variables":[{"_id":"6216422850294da359385e8d","key":"test","type":"Boolean"}],"variableHashes":{"test":2447239932}}')
puts(localbucketing.generate_bucketed_config('{"user_id":"test"}'))
puts("queue event")
localbucketing.queue_event('{"user_id":"test"}', '{ "type":"customEvent", "target":"testing"}')
puts("event queue size")
puts(localbucketing.check_event_queue_size)
puts("flush events")
flushed = localbucketing.flush_event_queue
puts(flushed)
puts(Oj.dump(flushed))

#
# test = DevCycle::PlatformData.new('server', '1.0.0', RUBY_VERSION, nil, 'Ruby', Socket.gethostname)
# puts(Oj.dump(test, options: {:mode => :compat}))
# puts(test.to_json)
