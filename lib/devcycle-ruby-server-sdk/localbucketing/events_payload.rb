require 'sorbet-runtime'

module DevCycle
  class EventsPayload
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