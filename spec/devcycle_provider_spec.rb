# frozen_string_literal: true

require 'spec_helper'

context 'user_from_openfeature_context' do
  context 'user_id' do

    it 'returns a user with the user_id from the context' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
    end

    it 'returns a user with the targeting_key from the context' do
      context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 'targeting_key')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('targeting_key')
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
  end

  context 'customData' do
    it 'returns a user with customData' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id', customData: { 'key' => 'value' })
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
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
  end
  context 'randomFields' do
    it 'returns a user with customData fields mapped to any non-standard fields' do
      context = OpenFeature::SDK::EvaluationContext.new(user_id: 'user_id', randomField: 'value')
      user = DevCycle::Provider.user_from_openfeature_context(context)
      expect(user.user_id).to eq('user_id')
      expect(user.customData).to eq({ 'randomField' => 'value' })
    end
  end
end
