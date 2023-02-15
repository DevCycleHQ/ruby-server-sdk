require 'sorbet-runtime'

module DevCycle
  class EventsPayload
    attr_reader :records
    attr_reader :payloadId
    attr_reader :eventCount

    def initialize(records, payloadId, eventCount)
      @records = records
      @payloadId = payloadId
      @eventCount = eventCount
    end
  end

  class EventsRecord
    def initialize(user, events)
      @user = user
      @events = events
    end

  end
end