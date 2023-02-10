require 'sorbet-runtime'

module DevCycle
  class EventsPayload
    extend T::Sig

    attr_accessor :records
    attr_accessor :payloadId

    sig { params(records: T::Array[EventsRecord], payloadId: String, eventCount: Integer).returns(Integer) }
    def initialize(records, payloadId, eventCount)
      @records = records
      @payloadId = payloadId
      @eventCount = eventCount
    end
  end

  class EventsRecord
    extend T::Sig

    attr_accessor :user
    attr_accessor :events

    sig { params(user: UserData, events: T::Array[Event]).returns(NilClass) }
    def initialize(user, events)
      @user = user
      @events = events
    end

  end
end