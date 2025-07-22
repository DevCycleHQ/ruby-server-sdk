# frozen_string_literal: true

require 'spec_helper'
require 'open_feature/sdk'

context 'user_from_openfeature_context' do
  context 'user_id validation' do
    it 'raises error when no user ID fields are provided' do
      context = OpenFeature::SDK::EvaluationContext.new(email: 'test@example.com')
      expect {
        DevCycle::Provider.user_from_openfeature_context(context)
      }.to raise_error(ArgumentError, "User ID is required. Must provide one of: targeting_key, user_id, or userId")
    end

    it 'raises error when targeting_key is not a string' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 123)
      expect {
        DevCycle::Provider.user_from_openfeature_context(context)
      }.to raise_error(ArgumentError, "User ID must be a string, got Integer")
    end

    it 'raises error when user_id is not a string' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 123)
      expect {
        DevCycle::Provider.user_from_openfeature_context(context)
      }.to raise_error(ArgumentError, "User ID must be a string, got Integer")
    end

    it 'raises error when userId is not a string' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: 123)
      expect {
        DevCycle::Provider.user_from_openfeature_context(context)
      }.to raise_error(ArgumentError, "User ID must be a string, got Integer")
    end

    it 'raises error when targeting_key is nil' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: nil)
      expect {
        DevCycle::Provider.user_from_openfeature_context(context)
      }.to raise_error(ArgumentError, "User ID is required. Must provide one of: targeting_key, user_id, or userId")
    end

    it 'raises error when targeting_key is empty string' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: '')
      expect {
        DevCycle::Provider.user_from_openfeature_context(context)
      }.to raise_error(ArgumentError, "User ID is required. Must provide one of: targeting_key, user_id, or userId")
    end

    it 'raises error when user_id is empty string' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: '')
      expect {
        DevCycle::Provider.user_from_openfeature_context(context)
      }.to raise_error(ArgumentError, "User ID is required. Must provide one of: targeting_key, user_id, or userId")
    end

    it 'raises error when userId is empty string' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: '')
      expect {
        DevCycle::Provider.user_from_openfeature_context(context)
      }.to raise_error(ArgumentError, "User ID is required. Must provide one of: targeting_key, user_id, or userId")
    end
  end

  context 'user_id fields priority' do
    it 'returns a user with the user_id from the context when only user_id is provided' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id_value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id_value')
    end

    it 'returns a user with the targeting_key from the context when only targeting_key is provided' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key_value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key_value')
    end

    it 'returns a user with the userId from the context when only userId is provided' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: 'userId_value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('userId_value')
    end

    it 'prioritizes targeting_key over user_id' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key_value', user_id: 'user_id_value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key_value')
      expect(user.customData).to eq({})
    end

    it 'prioritizes targeting_key over userId' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key_value', userId: 'userId_value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key_value')
      expect(user.customData).to eq({})
    end

    it 'prioritizes user_id over userId' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id_value', userId: 'userId_value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id_value')
      expect(user.customData).to eq({})
    end

    it 'prioritizes targeting_key over both user_id and userId' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key_value', user_id: 'user_id_value', userId: 'userId_value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key_value')
      expect(user.customData).to eq({})
    end
  end
  context 'email' do
    it 'returns a user with a valid user_id and email' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id', email: 'email')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
      expect(user.email).to eq('email')
    end
    it 'returns a user with a valid targeting_key and email' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key', email: 'email')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key')
      expect(user.email).to eq('email')
    end
    it 'returns a user with a valid userId and email' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: 'userId', email: 'email')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('userId')
      expect(user.email).to eq('email')
    end
    it 'prioritizes targeting_key over user_id with email' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key', user_id: 'user_id', email: 'email')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key')
      expect(user.email).to eq('email')
      expect(user.customData).to eq({})
    end
  end

  context 'customData' do
    it 'returns a user with customData' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id', customData: { 'key' => 'value' })
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
      expect(user.customData).to eq({ 'key' => 'value' })
    end
    it 'returns a user with userId and customData' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: 'userId', customData: { 'key' => 'value' })
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('userId')
      expect(user.customData).to eq({ 'key' => 'value' })
    end
    it 'excludes all user ID fields from customData' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key', user_id: 'user_id', userId: 'userId', customData: { 'key' => 'value' })
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key')
      expect(user.customData).to eq({ 'key' => 'value' })
    end
  end

  context 'privateCustomData' do
    it 'returns a user with privateCustomData' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id', privateCustomData: { 'key' => 'value' })
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
      expect(user.privateCustomData).to eq({ 'key' => 'value' })
    end
    it 'returns a user with userId and privateCustomData' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: 'userId', privateCustomData: { 'key' => 'value' })
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('userId')
      expect(user.privateCustomData).to eq({ 'key' => 'value' })
    end
  end

  context 'appVersion' do
    it 'returns a user with appVersion' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id', appVersion: '1.0.0')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
      expect(user.appVersion).to eq('1.0.0')
    end

    it 'returns a user with appBuild' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id', appBuild: 1)
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
      expect(user.appBuild).to eq(1)
    end

    it 'returns a user with userId and appVersion' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: 'userId', appVersion: '1.0.0')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('userId')
      expect(user.appVersion).to eq('1.0.0')
    end

    it 'returns a user with userId and appBuild' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: 'userId', appBuild: 1)
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('userId')
      expect(user.appBuild).to eq(1)
    end
  end
  context 'randomFields' do
    it 'returns a user with customData fields mapped to any non-standard fields' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id', randomField: 'value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
      expect(user.customData).to eq({ 'randomField' => 'value' })
    end

    it 'returns a user with userId and customData fields mapped to any non-standard fields' do
      context = OpenFeature::SDK::EvaluationContext.new(userId: 'userId', randomField: 'value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('userId')
      expect(user.customData).to eq({ 'randomField' => 'value' })
    end

    it 'excludes all user ID fields from custom data with random fields' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key', user_id: 'user_id', userId: 'userId', randomField: 'value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key')
      expect(user.customData).to eq({ 'randomField' => 'value' })
    end
  end

  context 'provider' do
    before(:all) do
      @dvc = DevCycle::Client.new('dvc_server_token_hash')
      OpenFeature::SDK.configure do |config|
        config.set_provider(@dvc.open_feature_provider)
      end
      @client = OpenFeature::SDK.build_client
      sleep(3)
    end
    it 'returns a provider with a valid client' do
      provider = @dvc.open_feature_provider
      expect(provider).to be_instance_of(DevCycle::Provider)
    end
    it 'responds properly to fetch_boolean_value' do
      expect(@client.fetch_boolean_value(flag_key: 'flag_key', default_value: false, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'user_id'))).to be(false)
    end
    it 'responds properly to fetch_string_value' do
      expect(@client.fetch_string_value(flag_key: 'flag_key', default_value: 'default', evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'user_id'))).to eq('default')
    end
    it 'responds properly to fetch_number_value' do
      expect(@client.fetch_number_value(flag_key: 'flag_key', default_value: 1, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'user_id'))).to eq(1)
    end
    it 'responds properly to fetch_integer_value' do
      expect(@client.fetch_integer_value(flag_key: 'flag_key', default_value: 1, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'user_id'))).to eq(1)
    end
    it 'responds properly to fetch_float_value' do
      expect(@client.fetch_float_value(flag_key: 'flag_key', default_value: 1.0, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'user_id'))).to eq(1.0)
    end
    it 'responds properly to fetch_object_value' do
      expect(@client.fetch_object_value(flag_key: 'flag_key', default_value: { 'key' => 'value' }, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'user_id'))).to eq({ 'key' => 'value' })
    end
    it 'returns a provider with a valid client' do
      provider = @dvc.open_feature_provider
      expect(provider).to be_instance_of(DevCycle::Provider)
    end
    it 'responds properly to fetch_boolean_value' do
      expect(@client.fetch_boolean_value(flag_key: 'test', default_value: false, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'test'))).to be(true)
    end
    it 'responds properly to fetch_string_value' do
      expect(@client.fetch_string_value(flag_key: 'test-string-variable', default_value: 'default', evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'test'))).not_to eq('default')
    end
    it 'responds properly to fetch_number_value' do
      expect(@client.fetch_number_value(flag_key: 'test-number-variable', default_value: 1, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'test'))).not_to eq(1)
    end
    it 'responds properly to fetch_integer_value' do
      expect(@client.fetch_integer_value(flag_key: 'test-number-variable', default_value: 1, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'test'))).not_to eq(1)
    end
    it 'responds properly to fetch_float_value' do
      expect(@client.fetch_float_value(flag_key: 'test-float-variable', default_value: 1.0, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'test'))).not_to eq(1.0)
    end
    it 'responds properly to fetch_object_value' do
      expect(@client.fetch_object_value(flag_key: 'test-json-variable', default_value: { 'key' => 'value' }, evaluation_context: OpenFeature::SDK::EvaluationContext.new(user_id:'test'))).not_to eq({ 'key' => 'value' })
    end
  end
end
