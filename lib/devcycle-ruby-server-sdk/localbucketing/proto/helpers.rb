def create_nullable_string(val)
  if val.nil? || val.empty?
    Proto::NullableString.new(value: "", isNull: true)
  else
    Proto::NullableString.new(value: val, isNull: false)
  end
end

def create_nullable_double(val)
  if val.nil?
    Proto::NullableDouble.new(value: 0, isNull: true)
  else
    Proto::NullableDouble.new(value: val, isNull: false)
  end
end

def create_nullable_custom_data(data)
  data_map = {}
  if data.nil? || data.length == 0
    return Proto::NullableCustomData.new(value: data_map, isNull: true)
  end

  data.each do |key, value|
    if value.nil?
      data_map[key] = Proto::CustomDataValue.new(type: Proto::CustomDataType::Null)
    end

    if value.is_a? String
      data_map[key] = Proto::CustomDataValue.new(type: Proto::CustomDataType::Str, stringValue: value)
    elsif value.is_a?(Float) || value.is_a?(Integer)
      data_map[key] = Proto::CustomDataValue.new(type: Proto::CustomDataType::Num, doubleValue: value)
    elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
      data_map[key] = Proto::CustomDataValue.new(type: Proto::CustomDataType::Bool, boolValue: value)
    end
  end

  Proto::NullableCustomData.new(value: data_map, isNull: false)
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