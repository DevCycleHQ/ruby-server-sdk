class DemoController < ApplicationController
  def index
    user = DevCycle::UserData.new({ user_id: 'test', country: 'JP' })
    @bool_var = Rails.configuration.dvc_client.variable(user, 'bool-var', false)
    @string_var = Rails.configuration.dvc_client.variable(user, 'string-var', 'default')
    @number_var = Rails.configuration.dvc_client.variable(user, 'number-var', 0)
    @json_var = Rails.configuration.dvc_client.variable(user, 'json-var-ruby-too', {})

    @non_existant_var = Rails.configuration.dvc_client.variable(user, 'non-existant-variable', "I don't exist")

    @all_variables = Rails.configuration.dvc_client.all_variables(user)

    @all_features = Rails.configuration.dvc_client.all_features(user)
  end

  def track
    user = DevCycle::UserData.new({
        user_id: 'test_' + rand(5).to_s,
        name: 'Mr. Test',
        email: 'mr_test@gmail.com',
        country: 'JP'
      })
    event = DevCycle::Event.new({ :'type' => :'randomEval', :'target' => :'custom target' })
    Rails.configuration.dvc_client.track(user, event)
    render json: "track called on DVC client"
  end

  def flush_events
    Rails.configuration.dvc_client.flush_events
    render json: "flush_events called on DVC client"
  end
end