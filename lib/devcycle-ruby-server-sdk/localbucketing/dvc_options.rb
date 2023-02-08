require 'oj'

module DevCycle
  class DVCOptions
    attr_accessor :enable_edge_db
    attr_accessor :enable_cloud_bucketing
    attr_accessor :event_flush_interval_ms
    attr_accessor :config_polling_interval_ms
    attr_accessor :request_timeout
    attr_accessor :disable_automatic_event_logging
    attr_accessor :disable_custom_event_logging
    attr_accessor :max_event_queue_size
    attr_accessor :flush_event_queue_size
    attr_accessor :config_cdn_uri
    attr_accessor :events_api_uri
    attr_accessor :bucketing_api_uri


    def default
      @event_flush_interval_ms = 1000
      @disable_custom_event_logging = false
      @disable_custom_event_logging = false
      @config_cdn_uri = "https://config-cdn.devcycle.com/"
      @events_api_uri = "https://events.devcycle.com/"
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