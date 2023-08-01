require 'typhoeus'
require 'sorbet-runtime'
require 'concurrent-ruby'

module DevCycle
  class EventQueue
    extend T::Sig

    sig { params(sdkKey: String, options: EventQueueOptions, local_bucketing: LocalBucketing).void }
    def initialize(sdkKey, options, local_bucketing)
      @sdkKey = sdkKey
      @events_api_uri = options.events_api_uri
      @logger = options.logger
      @event_flush_interval_ms = options.event_flush_interval_ms
      @flush_event_queue_size = options.flush_event_queue_size
      @max_event_queue_size = options.max_event_queue_size
      @flush_timer_task = Concurrent::TimerTask.new(
        execution_interval: @event_flush_interval_ms.fdiv(1000)
      ) {
        flush_events
      }
      @flush_timer_task.execute
      @flush_mutex = Mutex.new
      @local_bucketing = local_bucketing
      @local_bucketing.init_event_queue(options)
    end

    def close
      @flush_timer_task.shutdown
      flush_events
    end

    sig { returns(NilClass) }
    def flush_events
      @flush_mutex.synchronize do
        payloads = @local_bucketing.flush_event_queue
        if payloads.length == 0
          return
        end
        eventCount = payloads.reduce(0) { |sum, payload| sum + payload.eventCount }
        @logger.debug("DevCycle: Flushing #{eventCount} event(s) for #{payloads.length} user(s)")

        payloads.each do |payload|
          begin
            response = Typhoeus.post(
              @events_api_uri + '/v1/events/batch',
              headers: { 'Authorization': @sdkKey, 'Content-Type': 'application/json' },
              body: { 'batch': payload.records }.to_json
            )
            if response.code != 201
              @logger.error("Error publishing events, status: #{response.code}, body: #{response.return_message}")
              @local_bucketing.on_payload_failure(payload.payloadId, response.code >= 500)
            else
              @logger.debug("DevCycle: Flushed #{eventCount} event(s), for #{payload.records.length} user(s)")
              @local_bucketing.on_payload_success(payload.payloadId)
            end
          rescue => e
            @logger.error("DevCycle: Error Flushing Events response message: #{e.message}")
            @local_bucketing.on_payload_failure(payload.payloadId, false)
          end
        end
      end
      nil
    end

    # Todo: implement PopulatedUser
    sig { params(user: User, event: Event).returns(NilClass) }
    def queue_event(user, event)
      if max_event_queue_size_reached?
        @logger.warn("Max event queue size reached, dropping event: #{event}")
        return
      end

      @local_bucketing.queue_event(user, event)
      nil
    end

    sig { params(event: Event, bucketed_config: T.nilable(BucketedUserConfig)).returns(NilClass) }
    def queue_aggregate_event(event, bucketed_config)
      if max_event_queue_size_reached?
        @logger.warn("Max event queue size reached, dropping event: #{event}")
        return
      end

      @local_bucketing.queue_aggregate_event(event, bucketed_config)
      nil
    end

    sig { returns(T::Boolean) }
    def max_event_queue_size_reached?
      queue_size = @local_bucketing.check_event_queue_size()
      if queue_size >= @flush_event_queue_size
        flush_events
        if queue_size >= @max_event_queue_size
          return true
        end
      end
      false
    end
  end
end
