require "devcycle-ruby-server-sdk"
worker_processes 4
timeout 5
preload_app true
listen ENV['PORT'] || 3000, tcp_nopush: true
$DevCycleClient = nil

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |server, worker|
  $DevCycleClient = DevCycle::DVCClient.new(ENV['DVC_SERVER_SDK_KEY'], DevCycle::DVCOptions.new(enable_cloud_bucketing: false, event_flush_interval_ms: 1000, config_polling_interval_ms: 1000), true)
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
end