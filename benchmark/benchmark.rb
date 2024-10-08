require 'webmock'
require 'devcycle-ruby-server-sdk'
require 'benchmark'

include WebMock::API

WebMock.enable!
WebMock.disable_net_connect!

stub_request(:get, 'https://config-cdn.devcycle.com/config/v2/server/dvc_server_token_hash.json').
  to_return(headers: { 'Etag': 'test' }, body: File.new('../examples/local/local-bucketing-example/test_data/large_config.json'), status: 200)

stub_request(:post, 'https://events.devcycle.com/v1/events/batch').
  to_return(status: 201, body: '{}')

dvc_client = DevCycle::Client.new('dvc_server_token_hash', DevCycle::Options.new, true)
user = DevCycle::User.new({ user_id: 'test' })

n = 500
Benchmark.bm do |benchmark|
  benchmark.report('Single Variable Evaluation') do
    dvc_client.variable(user, 'v-key-25', false)
  end

  benchmark.report("#{n} Variable Evaluations") do
    n.times do
      dvc_client.variable(user, 'v-key-25', false)
    end
  end
end
