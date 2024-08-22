=begin
#DevCycle Bucketing API

#Documents the DevCycle Bucketing API which provides and API interface to User Bucketing and for generated SDKs.

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
OpenAPI Generator version: 5.3.0

=end

require 'spec_helper'
require 'json'

# Unit tests for DevCycle::Client
# Automatically generated by openapi-generator (https://openapi-generator.tech)
# Please update as you see appropriate
describe 'DevCycle::Client' do
  before(:all) do
    sdk_key = ENV["DEVCYCLE_SERVER_SDK_KEY"]
    if sdk_key.nil?
      puts("SDK KEY NOT SET - SKIPPING INIT")
      return
    end
    # run before each test
    options = DevCycle::Options.new(enable_cloud_bucketing: true)
    @api_instance = DevCycle::Client.new(sdk_key, options)
    
    @user = DevCycle::User.new({
        user_id: 'test-user',
        appVersion: '1.2.3'
    })
  end

  after do
    # run after each test
  end

  describe 'test an instance of DevcycleApi' do
    it 'should create an instance of DevcycleApi' do
      expect(@api_instance).to be_instance_of(DevCycle::Client)
    end
  end

  # unit tests for get_features
  # Get all features by key for user data
  # @param user
  # @param [Hash] opts the optional parameters
  # @return [Hash<String, Feature>]
  describe 'get_features test' do
    it 'should work' do # but it don't
      #result = @api_instance.all_features(@user)

      #expect(result.length).to eq 1
    end
  end

  # unit tests for get_variable_by_key
  # Get variable by key for user data
  # @param key Variable key
  # @param user
  # @param [Hash] opts the optional parameters
  # @return [Variable]
  describe 'get_variable_by_key ruby-example-tests' do
    it 'should work' do
      result = @api_instance.variable(@user, "ruby-example-tests", false)
      expect(result.isDefaulted).to eq true

      result = @api_instance.variable_value(@user, "ruby-example-tests", true)
      expect(result).to eq true
    end
  end

  # unit tests for get_variable_by_key
  # Get variable by key for user data
  # @param key Variable key
  # @param user
  # @param [Hash] opts the optional parameters
  # @return [Variable]
  describe 'get_variable_by_key test' do
    it 'should work' do
      result = @api_instance.variable(@user, "ruby-example-tests", false)
      expect(result.isDefaulted).to eq false
      expect(result.value).to eq true

      result = @api_instance.variable_value(@user, "ruby-example-tests", true)
      expect(result).to eq true
    end
  end

  # unit tests for get_variables
  # Get all variables by key for user data
  # @param user
  # @param [Hash] opts the optional parameters
  # @return [Hash<String, Variable>]
  describe 'get_variables test' do
    it 'should work' do
      result = @api_instance.all_variables(@user)

      expect(result.length).to eq 1
    end
  end

end
