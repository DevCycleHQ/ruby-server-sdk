=begin
#DevCycle Bucketing API

#Documents the DevCycle Bucketing API which provides and API interface to User Bucketing and for generated SDKs.

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
OpenAPI Generator version: 5.3.0

=end

require 'spec_helper'
require 'json'

# Unit tests for DevCycle::DVCClient
# Automatically generated by openapi-generator (https://openapi-generator.tech)
# Please update as you see appropriate
describe 'DVCClient' do
  before do
    # run before each test
    @api_instance = DevCycle::DVCClient.new

    DevCycle.configure do |config|
      # Configure API key authorization: bearerAuth
      config.api_key['bearerAuth'] = 'replaceWithValidSDKKey'
    end
    
    @user_data = DevCycle::UserData.new({
        user_id: 'my-user',
        app_version: '1.2.3'
    })
  end

  after do
    # run after each test
  end

  describe 'test an instance of DevcycleApi' do
    it 'should create an instance of DevcycleApi' do
      expect(@api_instance).to be_instance_of(DevCycle::DVCClient)
    end
  end

  # unit tests for get_features
  # Get all features by key for user data
  # @param user_data 
  # @param [Hash] opts the optional parameters
  # @return [Hash<String, Feature>]
  describe 'get_features test' do
    it 'should work' do
      result = @api_instance.all_features(@user_data);

      expect(result.length()).to eq 1
    end
  end

  # unit tests for get_variable_by_key
  # Get variable by key for user data
  # @param key Variable key
  # @param user_data 
  # @param [Hash] opts the optional parameters
  # @return [Variable]
  describe 'get_variable_by_key test' do
    it 'should work' do
      result = @api_instance.variable("activate-flag", @user_data, false)

      expect(result.isDefaulted).to eq false
    end
  end

  # unit tests for get_variables
  # Get all variables by key for user data
  # @param user_data 
  # @param [Hash] opts the optional parameters
  # @return [Hash<String, Variable>]
  describe 'get_variables test' do
    it 'should work' do
      result = @api_instance.all_variables(@user_data);

      expect(result.length()).to eq 1
    end
  end

  # unit tests for post_events
  # Post events to DevCycle for user
  # @param user_data_and_events_body 
  # @param [Hash] opts the optional parameters
  # @return [InlineResponse201]
  describe 'post_events test' do
    it 'should work' do
      event_data = DevCycle::Event.new({        
        type: "my-event",
        target: "some_event_target",
        value: 12,
        meta_data: {
            myKey: "my-value"
        }
    })

    result = @api_instance.track(@user_data, event_data)

    expect(result.message).to eq "Successfully received 1 events."
    end
  end

end
