# frozen_string_literal: true

require 'open_feature/sdk'

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
      resolve(flag_key, default_value, evaluation_context)
    end

    def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
      resolve(flag_key, default_value, evaluation_context)
    end

    def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
      resolve(flag_key, default_value, evaluation_context)
    end

    def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
      resolve(flag_key, default_value, evaluation_context) { |value| value.to_i }
    end

    def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
      resolve(flag_key, default_value, evaluation_context)
    end

    def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
      resolve(flag_key, default_value, evaluation_context)
    end

    def self.user_from_openfeature_context(context)
      unless context.is_a?(OpenFeature::SDK::EvaluationContext)
        raise ArgumentError, "Invalid context type, expected OpenFeature::SDK::EvaluationContext but got #{context.class}"
      end
      args = {}
      user_id = nil
      user_id_field = nil
      
      # Priority order: targeting_key -> user_id -> userId
      if context.field('targeting_key')
        user_id = context.field('targeting_key')
        user_id_field = 'targeting_key'
      elsif context.field('user_id')
        user_id = context.field('user_id')
        user_id_field = 'user_id'
      elsif context.field('userId')
        user_id = context.field('userId')
        user_id_field = 'userId'
      end
      
      # Validate user_id is present and is a string
      if user_id.nil?
        raise ArgumentError, "User ID is required. Must provide one of: targeting_key, user_id, or userId"
      end
      
      unless user_id.is_a?(String)
        raise ArgumentError, "User ID field '#{user_id_field}' must be a string, got #{user_id.class}"
      end
      
      # Check after type validation to avoid NoMethodError on non-strings
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

    # Maps a DevCycle evaluation reason onto an OpenFeature reason.
    def self.openfeature_reason(variable)
      reason = eval_field(variable, :reason)
      return reason if reason.is_a?(String) && !reason.empty?

      if variable.isDefaulted
        OpenFeature::SDK::Provider::Reason::DEFAULT
      else
        OpenFeature::SDK::Provider::Reason::TARGETING_MATCH
      end
    end

    # Surfaces DevCycle's evaluation details as OpenFeature flag metadata.
    def self.flag_metadata(variable)
      metadata = {}
      details = eval_field(variable, :details)
      target_id = eval_field(variable, :target_id)
      metadata[:details] = details unless details.nil?
      metadata[:target_id] = target_id unless target_id.nil?
      metadata
    end

    def self.eval_field(variable, key)
      eval_details = variable.eval
      return nil unless eval_details.is_a?(Hash)

      eval_details[key] || eval_details[key.to_s]
    end

    private

    # Evaluates a variable and wraps the result in the ResolutionDetails
    # structure that the OpenFeature SDK expects back from a provider.
    def resolve(flag_key, default_value, evaluation_context)
      user = Provider.user_from_openfeature_context(evaluation_context)
      variable = @client.variable(user, flag_key, default_value)

      value = variable.value
      value = yield(value) if block_given?

      OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: value,
        reason: Provider.openfeature_reason(variable),
        flag_metadata: Provider.flag_metadata(variable)
      )
    end
  end
end
