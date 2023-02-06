# frozen_string_literal: true

class DVCOptions

  EnableEdgeDB                 bool          `json:"enableEdgeDb,omitempty"`
  EnableCloudBucketing         bool          `json:"enableCloudBucketing,omitempty"`
  EventFlushIntervalMS         time.Duration `json:"eventFlushIntervalMS,omitempty"`
  ConfigPollingIntervalMS      time.Duration `json:"configPollingIntervalMS,omitempty"`
  RequestTimeout               time.Duration `json:"requestTimeout,omitempty"`
  DisableAutomaticEventLogging bool          `json:"disableAutomaticEventLogging,omitempty"`
  DisableCustomEventLogging    bool          `json:"disableCustomEventLogging,omitempty"`
  MaxEventQueueSize            int           `json:"maxEventsPerFlush,omitempty"`
  FlushEventQueueSize          int           `json:"minEventsPerFlush,omitempty"`
  ConfigCDNURI                 string
  EventsAPIURI                 string
  BucketingAPIURI              string

end
