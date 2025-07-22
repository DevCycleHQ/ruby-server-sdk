# frozen_string_literal: true

module DevCycle
  class Provider
    attr_reader :client
    def initialize(client)
      unless client.is_a?(DevCycle::Client)
        fail ArgumentError('Client must be an instance of DevCycleClient')
      end
      @client = client
    end

    def init
      # We handle all initialization on the DVC Client itself
    end

    def shutdown
      @client.close
    end

    def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
      # Retrieve a boolean value from provider source
      @client.variable(Provider.user_from_openfeature_context(evaluation_context), flag_key, default_value)
    end

    def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
      @client.variable(Provider.user_from_openfeature_context(evaluation_context), flag_key, default_value)
    end

    def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
      @client.variable(Provider.user_from_openfeature_context(evaluation_context), flag_key, default_value)
    end

    def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
      @client.variable(Provider.user_from_openfeature_context(evaluation_context), flag_key, default_value)
    end

    def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
      @client.variable(Provider.user_from_openfeature_context(evaluation_context), flag_key, default_value)
    end

    def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
      @client.variable(Provider.user_from_openfeature_context(evaluation_context), flag_key, default_value)
    end

    def self.user_from_openfeature_context(context)
      unless context.is_a?(OpenFeature::SDK::EvaluationContext)
        raise ArgumentError, "Invalid context type, expected OpenFeature::SDK::EvaluationContext but got #{context.class}"
      end
      args = {}
      user_id = nil
      
      # Priority order: targeting_key -> user_id -> userId
      if context.field('targeting_key')
        user_id = context.field('targeting_key')
      elsif context.field('user_id')
        user_id = context.field('user_id')
      elsif context.field('userId')
        user_id = context.field('userId')
      end
      
      # Validate user_id is present and is a string
      # Note: We can't merge the nil and empty checks because calling .empty? on
      # non-string values (like integers) would raise NoMethodError. We must check
      # the type first before calling string methods.
      if user_id.nil?
        raise ArgumentError, "User ID is required. Must provide one of: targeting_key, user_id, or userId"
      end
      
      unless user_id.is_a?(String)
        raise ArgumentError, "User ID must be a string, got #{user_id.class}"
      end
      
      if user_id.empty?
        raise ArgumentError, "User ID is required. Must provide one of: targeting_key, user_id, or userId"
      end
      
      args.merge!(user_id: user_id)
      
      customData = {}
      privateCustomData = {}
      context.fields.each do |field, value|
        # Skip all user ID fields from custom data
        if field === 'targeting_key' || field === 'user_id' || field === 'userId'
          next
        end
        if !(field === 'privateCustomData' || field === 'customData') && value.is_a?(Hash)
          next
        end
        case field
        when 'email'
          args.merge!(email: value)
        when 'name'
          args.merge!(name: value)
        when 'language'
          args.merge!(language: value)
        when 'country'
          args.merge!(country: value)
        when 'appVersion'
          if value.is_a?(String)
            args.merge!(appVersion: value)
          end
          next
        when 'appBuild'
          if value.is_a?(Numeric)
            args.merge!(appBuild: value)
          end
        when 'customData'
          if value.is_a?(Hash)
            customData.merge!(value)
          end
          next
        when 'privateCustomData'
          if value.is_a?(Hash)
            privateCustomData.merge!(value)
          end
        else
          customData.merge!(field => value)
        end
      end
      args.merge!(customData: customData)
      args.merge!(privateCustomData: privateCustomData)
      User.new(**args)
    end
  end
end
