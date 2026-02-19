module DevCycle
  class Options
    attr_reader :config_polling_interval_ms
    attr_reader :enable_edge_db
    attr_reader :enable_cloud_bucketing
    attr_reader :enable_beta_realtime_updates
    attr_reader :disable_realtime_updates
    attr_reader :config_cdn_uri
    attr_reader :events_api_uri
    attr_reader :bucketing_api_uri
    attr_reader :logger

    def initialize(
      enable_cloud_bucketing: false,
      event_flush_interval_ms: 10_000,
      disable_custom_event_logging: false,
      disable_automatic_event_logging: false,
      config_polling_interval_ms: 10_000,
      enable_beta_realtime_updates: false,
      disable_realtime_updates: false,
      request_timeout_ms: 5_000,
      max_event_queue_size: 2_000,
      flush_event_queue_size: 1_000,
      event_request_chunk_size: 100,
      logger: nil,
      config_cdn_uri: 'https://config-cdn.devcycle.com',
      events_api_uri: 'https://events.devcycle.com',
      enable_edge_db: false
    )
      @logger = logger || defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      @enable_cloud_bucketing = enable_cloud_bucketing

      @enable_edge_db = enable_edge_db

      if !@enable_cloud_bucketing && @enable_edge_db
        raise ArgumentError.new('Cannot enable edgedb without enabling cloud bucketing.')
      end

      if config_polling_interval_ms < 1000
        raise ArgumentError.new('config_polling_interval cannot be less than 1000ms')
      end
      @config_polling_interval_ms = config_polling_interval_ms

      if request_timeout_ms <= 5000
        request_timeout_ms = 5000
      end
      @request_timeout_ms = request_timeout_ms


      if event_flush_interval_ms < 500 || event_flush_interval_ms > (60 * 1000)
        raise ArgumentError.new('event_flush_interval_ms must be between 500ms and 1 minute')
      end
      @event_flush_interval_ms = event_flush_interval_ms

      if flush_event_queue_size >= max_event_queue_size
        raise ArgumentError.new(
          "flush_event_queue_size: #{flush_event_queue_size} must be " +
          "smaller than max_event_queue_size: #{@max_event_queue_size}"
        )
      elsif flush_event_queue_size < event_request_chunk_size || max_event_queue_size < event_request_chunk_size
        throw ArgumentError.new(
          "flush_event_queue_size: #{flush_event_queue_size} and " +
          "max_event_queue_size: #{max_event_queue_size} " +
          "must be larger than event_request_chunk_size: #{event_request_chunk_size}"
        )
      elsif flush_event_queue_size > 20000 || max_event_queue_size > 20000
        raise ArgumentError.new(
          "flush_event_queue_size: #{flush_event_queue_size} or " +
          "max_event_queue_size: #{max_event_queue_size} must be smaller than 20,000"
        )
      end
      @flush_event_queue_size = flush_event_queue_size
      @max_event_queue_size = max_event_queue_size
      @event_request_chunk_size = event_request_chunk_size

      @disable_custom_event_logging = disable_custom_event_logging
      @disable_automatic_event_logging = disable_automatic_event_logging

      if enable_beta_realtime_updates
        warn '[DEPRECATION] `enable_beta_realtime_updates` is deprecated and will be removed in a future release.'
      end
      @enable_beta_realtime_updates = enable_beta_realtime_updates
      @disable_realtime_updates = disable_realtime_updates
      @config_cdn_uri = config_cdn_uri
      @events_api_uri = events_api_uri
      @bucketing_api_uri = "https://bucketing-api.devcyle.com"
    end

    def event_queue_options
      EventQueueOptions.new(
        @event_flush_interval_ms,
        @disable_automatic_event_logging,
        @disable_custom_event_logging,
        @max_event_queue_size,
        @flush_event_queue_size,
        @events_api_uri,
        @event_request_chunk_size,
        @logger
      )
    end
  end

  class EventQueueOptions
    attr_reader :event_flush_interval_ms
    attr_reader :disable_automatic_event_logging
    attr_reader :disable_custom_event_logging
    attr_reader :max_event_queue_size
    attr_reader :flush_event_queue_size
    attr_reader :events_api_uri
    attr_reader :event_request_chunk_size
    attr_reader :logger

    def initialize (
      event_flush_interval_ms,
      disable_automatic_event_logging,
      disable_custom_event_logging,
      max_event_queue_size,
      flush_event_queue_size,
      events_api_uri,
      event_request_chunk_size,
      logger
    )
      @event_flush_interval_ms = event_flush_interval_ms
      @disable_automatic_event_logging = disable_automatic_event_logging
      @disable_custom_event_logging = disable_custom_event_logging
      @max_event_queue_size = max_event_queue_size
      @flush_event_queue_size = flush_event_queue_size
      @events_api_uri = events_api_uri
      @event_request_chunk_size = event_request_chunk_size
      @logger = logger
    end
  end

  # @deprecated Use `DevCycle::Options` instead.
  DVCOptions = Options
end
