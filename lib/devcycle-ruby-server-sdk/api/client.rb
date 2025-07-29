require 'cgi'
require 'logger'

module DevCycle
  class Client
    attr_reader :open_feature_provider
    def initialize(sdkKey, dvc_options = Options.new, wait_for_init = false)
      if sdkKey.nil?
        raise ArgumentError.new('Missing SDK key!')
      elsif !sdkKey.start_with?('server') && !sdkKey.start_with?('dvc_server')
        raise ArgumentError.new('Invalid SDK key!')
      end

      @sdkKey = sdkKey
      @dvc_options = dvc_options
      @logger = dvc_options.logger
      @eval_hooks_runner = EvalHooksRunner.new

      if @dvc_options.enable_cloud_bucketing
        @api_client = ApiClient.default
        @api_client.config.api_key['bearerAuth'] = @sdkKey
        @api_client.config.enable_edge_db = @dvc_options.enable_edge_db
        @api_client.config.logger = @logger
      else
        @local_bucketing = LocalBucketing.new(@sdkKey, dvc_options, wait_for_init)
        @event_queue = EventQueue.new(@sdkKey, dvc_options.event_queue_options, @local_bucketing)
      end
      @open_feature_provider = Provider.new(self)
    end

    def close
      if @dvc_options.enable_cloud_bucketing
        @logger.info("Cloud Bucketing does not require closing.")
        return
      end
      if @local_bucketing != nil
        if !@local_bucketing.initialized
          @logger.info("Awaiting client initialization before closing")
          while !@local_bucketing.initialized
            sleep(0.5)
          end
        end
        @local_bucketing.close
        @local_bucketing = nil
        @logger.info("Closed DevCycle Local Bucketing Engine.")
      end

      @event_queue.close
      @logger.info("Closed DevCycle Client.")
      nil
    end

    def set_client_custom_data(custom_data)
      if @dvc_options.enable_cloud_bucketing
        raise StandardError.new("Client Custom Data is only available in Local bucketing mode.")
      end

      if local_bucketing_initialized?
        @local_bucketing.set_client_custom_data(custom_data)
      else
        @logger.warn("Local bucketing not initialized. Unable to set client custom data.")
      end
      nil
    end

    def validate_model(model)
      return if model.valid?
      fail ArgumentError, "Invalid data provided for model #{model.class.name}: #{model.list_invalid_properties()}"
    end

    # Get all features by key for user data
    # @param user [User]
    # @param [Hash] opts the optional parameters
    # @return [Hash<String, Feature>]
    def all_features(user, opts = {})
      if !user.is_a?(DevCycle::User)
        fail ArgumentError, "user param must be an instance of DevCycle::User!"
      end

      validate_model(user)

      if @dvc_options.enable_cloud_bucketing
        data, _status_code, _headers = all_features_with_http_info(user, opts)
        return data
      end

      if local_bucketing_initialized? && @local_bucketing.has_config
        bucketed_config = @local_bucketing.generate_bucketed_config(user)
        bucketed_config.features
      else
        {}
      end
    end

    # Get all features by key for user data
    # @param user [User]
    # @param [Hash] opts the optional parameters
    # @return [Array<(Hash<String, Feature>, Integer, Hash)>] Hash<String, Feature> data, response status code and response headers
    def all_features_with_http_info(user, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: DevCycle::Client.all_features ...'
      end
      # verify the required parameter 'user' is set
      if @api_client.config.client_side_validation && user.nil?
        fail ArgumentError, "Missing the required parameter 'user' when calling DevCycle::Client.all_features"
      end
      # resource path
      local_var_path = '/v1/features'

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
        header_params['Content-Type'] = content_type
      end

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body] || user.to_json

      # return_type
      return_type = opts[:debug_return_type] || 'Hash<String, Feature>'

      # auth_names
      auth_names = opts[:debug_auth_names] || ['bearerAuth']

      new_options = opts.merge(
        :operation => :"Client.all_features",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: DevCycle::Client#all_features\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Get variable value by key for user data
    # @param user [User]
    # @param key [String] Variable key
    # @param default Default value for variable if none is retrieved
    # @param [Hash] opts the optional parameters
    # @return variable value which can be: string, number, boolean, or JSON
    def variable_value(user, key, default, opts = {})
      variable_obj = variable(user, key, default, opts)
      variable_obj.value
    end

    # Get variable by key for user data
    # @param user [DevCycle::User]
    # @param key [String] Variable key
    # @param default Default value for variable if none is retrieved
    # @param [Hash] opts the optional parameters
    # @return [Variable]
    def variable(user, key, default, opts = {})
      unless user.is_a?(DevCycle::User)
        fail ArgumentError, "user param must be an instance of DevCycle::User!"
      end

      validate_model(user)

      # Create hook context
      hook_context = HookContext.new(key: key, user: user, default_value: default)

      before_hook_error = nil
      # Run before hooks
      begin
        hook_context = @eval_hooks_runner.run_before_hooks(hook_context)
      rescue BeforeHookError => e
        before_hook_error = e
        @logger.warn("Error in before hooks: #{e.message}")
      end

      variable_result = nil

      begin
        if @dvc_options.enable_cloud_bucketing
          data, _status_code, _headers = variable_with_http_info(key, user, default, opts)
          variable_result = data
        else
          value = default
          type = determine_variable_type(default)
          defaulted = true
          eval = { reason: DevCycle::EVAL_REASONS::DEFAULT, details: DevCycle::DEFAULT_REASON_DETAILS::USER_NOT_TARGETED }
          if local_bucketing_initialized? && @local_bucketing.has_config
            type_code = variable_type_code_from_type(type)
            variable_pb = variable_for_user_pb(user, key, type_code)
            unless variable_pb.nil?
              value = get_variable_value(variable_pb)
              defaulted = false
            end
            eval = get_eval_reason(variable_pb)
          else
            eval = { reason: DevCycle::EVAL_REASONS::DEFAULT, details: DevCycle::DEFAULT_REASON_DETAILS::MISSING_CONFIG }
            @logger.warn("Local bucketing not initialized, returning default value for variable #{key}")
            variable_event = Event.new({ type: DevCycle::EventTypes[:agg_variable_defaulted], target: key, metaData: { evalReason: DevCycle::EVAL_REASONS::DEFAULT }})
            bucketed_config = BucketedUserConfig.new({}, {}, {}, {}, {}, {}, [])
            @event_queue.queue_aggregate_event(variable_event, bucketed_config)
          end

          variable_result = Variable.new({
            key: key,
            value: value,
            type: type,
            defaultValue: default,
            isDefaulted: defaulted,
            eval: eval
          })
        end


        # Run after hooks only if no before hook error occurred
        if before_hook_error != nil
          @logger.info("before_hook_error is not nil, skipping after hooks")
          raise before_hook_error
        else
          @eval_hooks_runner.run_after_hooks(hook_context)
        end
      rescue => e
        # Run error hooks
        @eval_hooks_runner.run_error_hooks(hook_context, e)
      ensure
        # Run finally hooks in all cases
        @eval_hooks_runner.run_finally_hooks(hook_context)
      end

      variable_result
    end

    def variable_for_user(user, key, variable_type_code)
      json_str = @local_bucketing.variable_for_user(user, key, variable_type_code)
      return nil if json_str.nil?
      JSON.parse(json_str)
    end

    def variable_for_user_pb(user, key, variable_type_code)
      user_data_pb = user.to_pb_user_data
      params_pb = Proto::VariableForUserParams_PB.new(
        sdkKey: @sdkKey,
        variableKey: key,
        variableType: variable_type_pb_code_from_type_code(variable_type_code),
        user: user_data_pb,
        shouldTrackEvent: true
      )
      param_bin_string = Proto::VariableForUserParams_PB.encode(params_pb)
      var_bin_string = @local_bucketing.variable_for_user_pb(param_bin_string)
      if var_bin_string.nil?
        return nil
      end
      Proto::SDKVariable_PB.decode(var_bin_string)
    end

    # Get variable by key for user data
    # @param key [String] Variable key
    # @param user [User]
    # @param default Default value for variable if none is retrieved
    # @param [Hash] opts the optional parameters
    # @return [Array<(Variable, Integer, Hash)>] Variable data, response status code and response headers
    def variable_with_http_info(key, user, default, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: DevCycle::Client.variable ...'
      end
      # verify the required parameter 'key' is set
      if @api_client.config.client_side_validation && key.nil?
        fail ArgumentError, "Missing the required parameter 'key' when calling DevCycle::Client.variable"
      end
      # verify the required parameter 'user' is set
      if @api_client.config.client_side_validation && user.nil?
        fail ArgumentError, "Missing the required parameter 'user' when calling DevCycle::Client.variable"
      end
      # resource path
      local_var_path = '/v1/variables/{key}'.sub('{' + 'key' + '}', CGI.escape(key.to_s))

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
        header_params['Content-Type'] = content_type
      end

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body] || user.to_json

      # return_type
      return_type = opts[:debug_return_type] || 'Variable'

      # auth_names
      auth_names = opts[:debug_auth_names] || ['bearerAuth']

      new_options = opts.merge(
        :operation => :"Client.variable",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      begin
        data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
        if @api_client.config.debugging
          @api_client.config.logger.debug "API called: DevCycle::Client#variable\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
        end
        if default && data.type && data.type.to_s != default.class.name
          eval = { reason: DevCycle::EVAL_REASONS::DEFAULT, details: DevCycle::DEFAULT_REASON_DETAILS::TYPE_MISMATCH }
          return Variable.new(key: key, value: default, isDefaulted: true, eval: eval)
        end
        return data
      rescue ApiError => error
        eval = { reason: DevCycle::EVAL_REASONS::DEFAULT, details: DevCycle::DEFAULT_REASON_DETAILS::MISSING_VARIABLE }
        if error.code != 404
          @api_client.config.logger.error("Failed to retrieve variable value: #{error.message}")
          eval[:details] = DevCycle::DEFAULT_REASON_DETAILS::ERROR
        end

        return Variable.new(key: key, value: default, isDefaulted: true, eval: eval)
      end 
    end

    # Get all variables by key for user data
    # @param user [User]
    # @param [Hash] opts the optional parameters
    # @return [Hash<String, Variable>]
    def all_variables(user, opts = {})
      if !user.is_a?(DevCycle::User)
        fail ArgumentError, "user param must be an instance of DevCycle::User!"
      end

      validate_model(user)

      if @dvc_options.enable_cloud_bucketing
        data, _status_code, _headers = all_variables_with_http_info(user, opts)
        return data
      end

      if local_bucketing_initialized? && @local_bucketing.has_config
        bucketed_config = @local_bucketing.generate_bucketed_config(user)
        bucketed_config.variables
      else
        {}
      end
    end

    # Get all variables by key for user data
    # @param user [User]
    # @param [Hash] opts the optional parameters
    # @return [Array<(Hash<String, Variable>, Integer, Hash)>] Hash<String, Variable> data, response status code and response headers
    def all_variables_with_http_info(user, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: DevCycle::Client.all_variables ...'
      end
      # verify the required parameter 'user' is set
      if @api_client.config.client_side_validation && user.nil?
        fail ArgumentError, "Missing the required parameter 'user' when calling DevCycle::Client.all_variables"
      end
      # resource path
      local_var_path = '/v1/variables'

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
        header_params['Content-Type'] = content_type
      end

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body] || user.to_json

      # return_type
      return_type = opts[:debug_return_type] || 'Hash<String, Variable>'

      # auth_names
      auth_names = opts[:debug_auth_names] || ['bearerAuth']

      new_options = opts.merge(
        :operation => :"Client.all_variables",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: DevCycle::Client#all_variables\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Post events to DevCycle for user
    # @param user [User]
    # @param event_data [Event]
    # @param [Hash] opts the optional parameters
    # @return [InlineResponse201]
    def track(user, event_data, opts = {})
      if !user.is_a?(DevCycle::User)
        fail ArgumentError, "user param must be an instance of DevCycle::User!"
      end

      validate_model(user)

      if !event_data.is_a?(DevCycle::Event)
        fail ArgumentError, "event_data param must be an instance of DevCycle::Event!"
      end

      validate_model(event_data)

      if @dvc_options.enable_cloud_bucketing
        track_with_http_info(user, event_data, opts)
        return
      end

      if local_bucketing_initialized?
        @event_queue.queue_event(user, event_data)
      else
        @logger.warn('track called before DevCycle::Client initialized, event will not be tracked')
      end
    end

    # Post events to DevCycle for user
    # @param user [User]
    # @param event_data [Event]
    # @param [Hash] opts the optional parameters
    # @return [Array<(InlineResponse201, Integer, Hash)>] InlineResponse201 data, response status code and response headers
    def track_with_http_info(user, event_data, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: DevCycle::Client.post_events ...'
      end
      # verify the required parameter 'user_data_and_events_body' is set
      if @api_client.config.client_side_validation && (user.nil? || event_data.nil?)
        fail ArgumentError, "Missing the required parameter 'user_data_and_events_body' when calling DevCycle::Client.post_events"
      end

      user_data_and_events_body = DevCycle::UserDataAndEventsBody.new({
                                                                        user: user,
                                                                        events: [event_data]
                                                                      })

      # resource path
      local_var_path = '/v1/track'

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
        header_params['Content-Type'] = content_type
      end

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body] || @api_client.object_to_http_body(user_data_and_events_body)

      # if post_body.user.respond_to?(:to_hash)
      #   post_body.user = post_body.user.to_hash()

      # return_type
      return_type = opts[:debug_return_type] || 'InlineResponse201'

      # auth_names
      auth_names = opts[:debug_auth_names] || ['bearerAuth']

      new_options = opts.merge(
        :operation => :"Client.post_events",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: DevCycle::Client#post_events\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    def flush_events
      @event_queue.flush_events
    end

    def local_bucketing_initialized?
      !@local_bucketing.nil? && @local_bucketing.initialized
    end

    def determine_variable_type(variable_value)
      if variable_value.is_a?(String)
        'String'
      elsif variable_value.is_a?(TrueClass) || variable_value.is_a?(FalseClass)
        'Boolean'
      elsif variable_value.is_a?(Integer) || variable_value.is_a?(Float)
        'Number'
      elsif variable_value.is_a?(Hash)
        'JSON'
      else
        raise ArgumentError, "Invalid type for variable: #{variable_value}"
      end
    end

    def variable_type_code_from_type(type)
      case type
      when 'String'
        @local_bucketing.variable_type_codes[:string]
      when 'Boolean'
        @local_bucketing.variable_type_codes[:boolean]
      when 'Number'
        @local_bucketing.variable_type_codes[:number]
      when 'JSON'
        @local_bucketing.variable_type_codes[:json]
      else
        raise ArgumentError.new("Invalid type for variable: #{type}")
      end
    end

    def variable_type_pb_code_from_type_code(type_code)
      case type_code
      when @local_bucketing.variable_type_codes[:string]
        Proto::VariableType_PB::String
      when @local_bucketing.variable_type_codes[:boolean]
        Proto::VariableType_PB::Boolean
      when @local_bucketing.variable_type_codes[:number]
        Proto::VariableType_PB::Number
      when @local_bucketing.variable_type_codes[:json]
        Proto::VariableType_PB::JSON
      else
        raise ArgumentError.new("Invalid type code for variable: #{type_code}")
      end
    end

    def get_variable_value(variable_pb)
      case variable_pb.type
      when :Boolean
        variable_pb.boolValue
      when :Number
        variable_pb.doubleValue
      when :String
        variable_pb.stringValue
      when :JSON
        JSON.parse variable_pb.stringValue
      end
    end

    def get_eval_reason(variable_pb)
      if variable_pb.nil?
        { reason: DevCycle::EVAL_REASONS::DEFAULT, details: DevCycle::DEFAULT_REASON_DETAILS::USER_NOT_TARGETED}
      else
        if variable_pb.eval.nil?
          { reason: DevCycle::EVAL_REASONS::DEFAULT, details: DevCycle::DEFAULT_REASON_DETAILS::USER_NOT_TARGETED }
        else
          { reason: variable_pb.eval.reason, details: variable_pb.eval.details, target_id: variable_pb.eval.target_id }
        end
      end
    end

    # Adds an eval hook to the client
    # @param [EvalHook] eval_hook The eval hook to add
    # @return [void]
    def add_eval_hook(eval_hook)
      @eval_hooks_runner.add_hook(eval_hook)
    end

    # Clears all eval hooks from the client
    # @return [void]
    def clear_eval_hooks
      @eval_hooks_runner.clear_hooks
    end
  end

  # @deprecated Use `DevCycle::Client` instead.
  DVCClient = Client
end
