# frozen_string_literal: true

class DevCycleProvider

  def initialize(client)
    @client = client
  end
  def init
    # We handle all initialization on the DVC Client itself
  end

  def shutdown
    @client.close()
  end

  def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)

  end

  def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
    # Retrieve a string value from provider source
  end

  def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
    # Retrieve a numeric value from provider source
  end

  def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
    # Retrieve a integer value from provider source
  end

  def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
    # Retrieve a float value from provider source
  end

  def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
    # Retrieve a hash value from provider source
  end


end
