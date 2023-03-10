=begin
#DevCycle Bucketing API

#Documents the DevCycle Bucketing API which provides and API interface to User Bucketing and for generated SDKs.

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
OpenAPI Generator version: 5.3.0

=end

require 'cgi'
require 'logger'

module DevCycle
  class DVCClient
    def initialize(sdkKey, dvc_options = DVCOptions.new, wait_for_init = false)
      if sdkKey.nil?
        raise ArgumentError.new('Missing SDK key!')
      elsif !sdkKey.start_with?('server') && !sdkKey.start_with?('dvc_server')
        raise ArgumentError.new('Invalid SDK key!')
      end

      @sdkKey = sdkKey
      @dvc_options = dvc_options
      @logger = dvc_options.logger

      if @dvc_options.enable_cloud_bucketing
        @api_client = ApiClient.default
        @api_client.config.api_key['bearerAuth'] = @sdkKey
        @api_client.config.enable_edge_db = @dvc_options.enable_edge_db
        @api_client.config.logger = @logger
      else
        @localbucketing = LocalBucketing.new(@sdkKey, dvc_options, wait_for_init)
        @event_queue = EventQueue.new(@sdkKey, dvc_options.event_queue_options, @localbucketing)
      end
    end

    def close
      if @dvc_options.enable_cloud_bucketing
        @logger.info("Cloud Bucketing does not require closing.")
        return
      end
      if @localbucketing != nil
        if !@localbucketing.initialized
          @logger.info("Awaiting client initialization before closing")
          while !@localbucketing.initialized
            sleep(0.5)
          end
        end
        @localbucketing.close
        @localbucketing = nil
        @logger.info("Closed DevCycle Local Bucketing Engine.")
      end

      @event_queue.close
      @logger.info("Closed DevCycle Client.")
      nil
    end

    # NOTE: Feature not supported yet
    # def set_client_custom_data(customdata)
    #   if @dvc_options.enable_cloud_bucketing
    #     raise StandardError.new("Client Custom Data is only available in Local bucketing mode.")
    #   end

    #   if local_bucketing_initialized?
    #     @localbucketing.set_client_custom_data(customdata)
    #   else
    #     @logger.warn("Local bucketing not initialized. Unable to set client custom data.")
    #   end
    #   nil
    # end

    def validate_model(model)
      return if model.valid?
      fail ArgumentError, "Invalid data provided for model #{model.class.name}: #{model.list_invalid_properties()}"
    end

    # Get all features by key for user data
    # @param user_data [UserData]
    # @param [Hash] opts the optional parameters
    # @return [Hash<String, Feature>]
    def all_features(user_data, opts = {})
      if !user_data.is_a?(DevCycle::UserData)
        fail ArgumentError, "user_data param must be an instance of UserData!"
      end

      validate_model(user_data)

      if @dvc_options.enable_cloud_bucketing
        data, _status_code, _headers = all_features_with_http_info(user_data, opts)
        return data
      end

      if local_bucketing_initialized? && @localbucketing.has_config
        bucketed_config = @localbucketing.generate_bucketed_config(user_data)
        bucketed_config.features
      else
        {}
      end
    end

    # Get all features by key for user data
    # @param user_data [UserData]
    # @param [Hash] opts the optional parameters
    # @return [Array<(Hash<String, Feature>, Integer, Hash)>] Hash<String, Feature> data, response status code and response headers
    def all_features_with_http_info(user_data, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: DVCClient.all_features ...'
      end
      # verify the required parameter 'user_data' is set
      if @api_client.config.client_side_validation && user_data.nil?
        fail ArgumentError, "Missing the required parameter 'user_data' when calling DVCClient.all_features"
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
      post_body = opts[:debug_body] || user_data.to_json

      # return_type
      return_type = opts[:debug_return_type] || 'Hash<String, Feature>'

      # auth_names
      auth_names = opts[:debug_auth_names] || ['bearerAuth']

      new_options = opts.merge(
        :operation => :"DVCClient.all_features",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: DVCClient#all_features\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Get variable by key for user data
    # @param user_data [UserData]
    # @param key [String] Variable key
    # @param default Default value for variable if none is retrieved
    # @param [Hash] opts the optional parameters
    # @return [Variable]
    def variable(user_data, key, default, opts = {})
      if !user_data.is_a?(DevCycle::UserData)
        fail ArgumentError, "user_data param must be an instance of UserData!"
      end

      validate_model(user_data)

      if @dvc_options.enable_cloud_bucketing
        data, _status_code, _headers = variable_with_http_info(key, user_data, default, opts)
        return data
      end

      if local_bucketing_initialized? && @localbucketing.has_config
        bucketed_config = @localbucketing.generate_bucketed_config(user_data)
        variable_json = bucketed_config.variables[key]
        if variable_json == nil
          @logger.warn("No variable found for key #{key}, returning default value")
          variable_event = Event.new({ type: DevCycle::EventTypes[:agg_variable_defaulted], target: key })
          @event_queue.queue_aggregate_event(variable_event, bucketed_config)

          return Variable.new({
            key: key,
            type: determine_variable_type(default),
            value: default,
            defaultValue: default,
            isDefaulted: true
          })
        end
        default_type = determine_variable_type(default)
        variable_type = variable_json['type']
        if default_type != variable_type
          @logger.warn("Type mismatch for variable #{key}, returning default value")
          variable_event = Event.new({ type: DevCycle::EventTypes[:agg_variable_defaulted], target: key })
          @event_queue.queue_aggregate_event(variable_event, bucketed_config)

          return Variable.new({
            key: key,
            type: default_type,
            value: default,
            defaultValue: default,
            isDefaulted: true
          })
        end
        variable_event = Event.new({ type: DevCycle::EventTypes[:agg_variable_evaluated], target: key })
        @event_queue.queue_aggregate_event(variable_event, bucketed_config)

        Variable.new({
          key: key,
          type: variable_type,
          value: variable_json['value'],
          defaultValue: default,
          isDefaulted: false
        })
      else
        @logger.warn("Local bucketing not initialized, returning default value for variable #{key}")
        variable_event = Event.new({ type: DevCycle::EventTypes[:agg_variable_defaulted], target: key })
        @event_queue.queue_aggregate_event(variable_event, bucketed_config)

        Variable.new({
          key: key,
          type: determine_variable_type(default),
          value: default,
          defaultValue: default,
          isDefaulted: true
        })
      end
    end

    # Get variable by key for user data
    # @param key [String] Variable key
    # @param user_data [UserData]
    # @param default Default value for variable if none is retrieved
    # @param [Hash] opts the optional parameters
    # @return [Array<(Variable, Integer, Hash)>] Variable data, response status code and response headers
    def variable_with_http_info(key, user_data, default, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: DVCClient.variable ...'
      end
      # verify the required parameter 'key' is set
      if @api_client.config.client_side_validation && key.nil?
        fail ArgumentError, "Missing the required parameter 'key' when calling DVCClient.variable"
      end
      # verify the required parameter 'user_data' is set
      if @api_client.config.client_side_validation && user_data.nil?
        fail ArgumentError, "Missing the required parameter 'user_data' when calling DVCClient.variable"
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
      post_body = opts[:debug_body] || user_data.to_json

      # return_type
      return_type = opts[:debug_return_type] || 'Variable'

      # auth_names
      auth_names = opts[:debug_auth_names] || ['bearerAuth']

      new_options = opts.merge(
        :operation => :"DVCClient.variable",
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
          @api_client.config.logger.debug "API called: DVCClient#variable\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
        end
        return data
      rescue ApiError => error
        if error.code != 404
          @api_client.config.logger.error("Failed to retrieve variable value: #{error.message}")
        end

        return Variable.new(key: key, value: default, isDefaulted: true)
      end
    end

    # Get all variables by key for user data
    # @param user_data [UserData]
    # @param [Hash] opts the optional parameters
    # @return [Hash<String, Variable>]
    def all_variables(user_data, opts = {})
      if !user_data.is_a?(DevCycle::UserData)
        fail ArgumentError, "user_data param must be an instance of UserData!"
      end

      validate_model(user_data)

      if @dvc_options.enable_cloud_bucketing
        data, _status_code, _headers = all_variables_with_http_info(user_data, opts)
        return data
      end

      if local_bucketing_initialized? && @localbucketing.has_config
        bucketed_config = @localbucketing.generate_bucketed_config(user_data)
        bucketed_config.variables
      else
        {}
      end
    end

    # Get all variables by key for user data
    # @param user_data [UserData]
    # @param [Hash] opts the optional parameters
    # @return [Array<(Hash<String, Variable>, Integer, Hash)>] Hash<String, Variable> data, response status code and response headers
    def all_variables_with_http_info(user_data, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: DVCClient.all_variables ...'
      end
      # verify the required parameter 'user_data' is set
      if @api_client.config.client_side_validation && user_data.nil?
        fail ArgumentError, "Missing the required parameter 'user_data' when calling DVCClient.all_variables"
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
      post_body = opts[:debug_body] || user_data.to_json

      # return_type
      return_type = opts[:debug_return_type] || 'Hash<String, Variable>'

      # auth_names
      auth_names = opts[:debug_auth_names] || ['bearerAuth']

      new_options = opts.merge(
        :operation => :"DVCClient.all_variables",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: DVCClient#all_variables\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Post events to DevCycle for user
    # @param user_data [UserData]
    # @param event_data [Event]
    # @param [Hash] opts the optional parameters
    # @return [InlineResponse201]
    def track(user_data, event_data, opts = {})
      if !user_data.is_a?(DevCycle::UserData)
        fail ArgumentError, "user_data param must be an instance of UserData!"
      end

      validate_model(user_data)

      if !event_data.is_a?(DevCycle::Event)
        fail ArgumentError, "event_data param must be an instance of Event!"
      end

      validate_model(event_data)

      if @dvc_options.enable_cloud_bucketing
        track_with_http_info(user_data, event_data, opts)
        return
      end

      if local_bucketing_initialized?
        @event_queue.queue_event(user_data, event_data)
      else
        @logger.warn('track called before DVCClient initialized, event will not be tracked')
      end
    end

    # Post events to DevCycle for user
    # @param user_data [UserData]
    # @param event_data [Event]
    # @param [Hash] opts the optional parameters
    # @return [Array<(InlineResponse201, Integer, Hash)>] InlineResponse201 data, response status code and response headers
    def track_with_http_info(user_data, event_data, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: DVCClient.post_events ...'
      end
      # verify the required parameter 'user_data_and_events_body' is set
      if @api_client.config.client_side_validation && (user_data.nil? || event_data.nil?)
        fail ArgumentError, "Missing the required parameter 'user_data_and_events_body' when calling DVCClient.post_events"
      end

      user_data_and_events_body = DevCycle::UserDataAndEventsBody.new({
                                                                        user: user_data,
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
        :operation => :"DVCClient.post_events",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: DVCClient#post_events\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    def flush_events
      @event_queue.flush_events
    end

    def local_bucketing_initialized?
      !@localbucketing.nil? && @localbucketing.initialized
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
  end
end
