require 'oj'

module DevCycle
  class DVCOptions
    attr_accessor :enable_edge_db
    attr_accessor :enable_cloud_bucketing
    attr_accessor :event_flush_interval_ms
    attr_accessor :config_polling_interval_ms
    attr_accessor :request_timeout_ms
    attr_accessor :disable_automatic_event_logging
    attr_accessor :disable_custom_event_logging
    attr_accessor :max_event_queue_size
    attr_accessor :flush_event_queue_size
    attr_accessor :config_cdn_uri
    attr_accessor :events_api_uri
    attr_accessor :bucketing_api_uri
    attr_accessor :logger

    def initialize(event_flush_interval_ms = 1000,
                   disable_custom_event_logging = false,
                   disable_automatic_event_logging = false,
                   config_polling_interval_ms = 10000,
                   request_timeout_ms = 5000,
                   max_event_queue_size = 10000,
                   flush_event_queue_size = 1000,
                   logger = nil)
      if event_flush_interval_ms < 500 || event_flush_interval_ms > 60000
        puts("Event Flush interval must be between 500ms to 60000ms. Defaulting to 30000ms")
        event_flush_interval_ms = 30000
      end
      @event_flush_interval_ms = event_flush_interval_ms

      if config_polling_interval_ms < 1000
        puts("Config polling interval cannot be less than 1000ms, defaulting to 10000ms")
        config_polling_interval_ms = 10000
      end
      @config_polling_interval_ms = config_polling_interval_ms

      if request_timeout_ms <= 5000
        request_timeout_ms = 5000
      end
      @request_timeout_ms = request_timeout_ms

      if max_event_queue_size <= 0
        max_event_queue_size = 10000
      end
      @max_event_queue_size = max_event_queue_size

      if flush_event_queue_size <= 0
        flush_event_queue_size = 1000
      end

      @logger = logger || defined?(Rails) ? Rails.logger : Logger.new(STDOUT)

      @flush_event_queue_size = flush_event_queue_size
      @disable_custom_event_logging = disable_custom_event_logging
      @disable_automatic_event_logging = disable_automatic_event_logging
      @config_cdn_uri = "https://config-cdn.devcycle.com"
      @events_api_uri = "https://events.devcycle.com"
      @bucketing_api_uri = "https://bucketing-api.devcyle.com"
    end

    def event_queue_options
      EventQueueOptions.new(@event_flush_interval_ms, @disable_automatic_event_logging, @disable_custom_event_logging)
    end
  end

  class EventQueueOptions
    attr_accessor :flushEventsMS
    attr_accessor :disableAutomaticEventLogging
    attr_accessor :disableCustomEventLogging

    def initialize (flushEventsMS, disableAutomaticEventLogging, disableCustomEventLogging)
      @flushEventsMS = flushEventsMS
      @disableAutomaticEventLogging = disableAutomaticEventLogging
      @disableCustomEventLogging = disableCustomEventLogging
    end
  end
end