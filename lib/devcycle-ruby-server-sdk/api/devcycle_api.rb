=begin
#DevCycle Bucketing API

#Documents the DevCycle Bucketing API which provides and API interface to User Bucketing and for generated SDKs.

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
OpenAPI Generator version: 5.3.0

=end

require 'cgi'

module DevCycle
  class DVCClient
    attr_accessor :api_client

    def initialize(api_client = ApiClient.default)
      @api_client = api_client
    end

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

      data, _status_code, _headers = all_features_with_http_info(user_data, opts)
      data
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
      post_body = opts[:debug_body] || @api_client.object_to_http_body(user_data)

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
    # @param key [String] Variable key
    # @param user_data [UserData]
    # @param default Default value for variable if none is retrieved
    # @param [Hash] opts the optional parameters
    # @return [Variable]
    def variable(key, user_data, default, opts = {})
      if !user_data.is_a?(DevCycle::UserData)
        fail ArgumentError, "user_data param must be an instance of UserData!"
      end

      validate_model(user_data)

      data, _status_code, _headers = variable_with_http_info(key, user_data, default, opts)
      data
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
      post_body = opts[:debug_body] || @api_client.object_to_http_body(user_data)

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

      data, _status_code, _headers = all_variables_with_http_info(user_data, opts)
      data
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
      post_body = opts[:debug_body] || @api_client.object_to_http_body(user_data)

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

      data, _status_code, _headers = track_with_http_info(user_data, event_data, opts)
      data
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
  end
end