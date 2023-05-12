class DemoController < ApplicationController
  def index
    user = DevCycle::UserData.new({ user_id: 'test', country: 'JP' })
    @bool_var = DevCycleClient.variable_value(user, 'bool-var', false)
    @string_var = DevCycleClient.variable_value(user, 'string-var', 'default')
    @number_var = DevCycleClient.variable_value(user, 'number-var', 0)
    @json_var = DevCycleClient.variable_value(user, 'json-var-ruby-too', {})

    @non_existent_var = DevCycleClient.variable_value(user, 'non-existent-variable', "I don't exist")

    @all_variables = DevCycleClient.all_variables(user)

    @all_features = DevCycleClient.all_features(user)
  end

  def track
    user = DevCycle::UserData.new({
        user_id: 'test_' + rand(5).to_s,
        name: 'Mr. Test',
        email: 'mr_test@gmail.com',
        country: 'JP'
      })
    event = DevCycle::Event.new({ :'type' => :'randomEval', :'target' => :'custom target' })
    DevCycleClient.track(user, event)
    render json: "track called on DVC client"
  end

  def flush_events
    DevCycleClient.flush_events
    render json: "flush_events called on DVC client"
  end

  def variable
    user = DevCycle::UserData.new({ user_id: 'test' })
    variable = DevCycleClient.variable(user, 'v-key-25', false)
    render json: variable
  end
end