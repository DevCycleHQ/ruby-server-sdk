require 'date'
require 'time'
require 'oj'

module DevCycle
  class User

    # Unique id to identify the user
    attr_accessor :user_id

    # User's email used to identify the user on the dashboard / target audiences
    attr_accessor :email

    # User's name used to identify the user on the dashboard / target audiences
    attr_accessor :name

    # User's language in ISO 639-1 format
    attr_accessor :language

    # User's country in ISO 3166 alpha-2 format
    attr_accessor :country

    # App Version of the running application
    attr_accessor :appVersion

    # App Build number of the running application
    attr_accessor :appBuild

    # User's custom data to target the user with, data will be logged to DevCycle for use in dashboard.
    attr_accessor :customData

    # User's custom data to target the user with, data will not be logged to DevCycle only used for feature bucketing.
    attr_accessor :privateCustomData

    # User's device model
    attr_accessor :deviceModel

    # read-only instance variables

    # Date the user was created, Unix epoch timestamp format
    attr_reader :createdDate

    # Date the user was created, Unix epoch timestamp format
    attr_reader :lastSeenDate

    # Platform the Client SDK is running on
    attr_reader :platform

    # Version of the platform the Client SDK is running on
    attr_reader :platformVersion

    # DevCycle SDK type
    attr_reader :sdkType

    # DevCycle SDK Version
    attr_reader :sdkVersion

    class EnumAttributeValidator
      attr_reader :datatype
      attr_reader :allowable_values

      def initialize(datatype, allowable_values)
        @allowable_values = allowable_values.map do |value|
          case datatype.to_s
          when /Integer/i
            value.to_i
          when /Float/i
            value.to_f
          else
            value
          end
        end
      end

      def valid?(value)
        !value || allowable_values.include?(value)
      end
    end

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'user_id' => :'user_id',
        :'email' => :'email',
        :'name' => :'name',
        :'language' => :'language',
        :'country' => :'country',
        :'appVersion' => :'appVersion',
        :'appBuild' => :'appBuild',
        :'customData' => :'customData',
        :'privateCustomData' => :'privateCustomData',
        :'createdDate' => :'createdDate',
        :'lastSeenDate' => :'lastSeenDate',
        :'platform' => :'platform',
        :'platformVersion' => :'platformVersion',
        :'deviceModel' => :'deviceModel',
        :'sdkType' => :'sdkType',
        :'sdkVersion' => :'sdkVersion'
      }
    end

    # Returns all the JSON keys this model knows about
    def self.acceptable_attributes
      attribute_map.values
    end

    # Attribute type mapping.
    def self.openapi_types
      {
        :'user_id' => :'String',
        :'email' => :'String',
        :'name' => :'String',
        :'language' => :'String',
        :'country' => :'String',
        :'appVersion' => :'String',
        :'appBuild' => :'String',
        :'customData' => :'Object',
        :'privateCustomData' => :'Object',
        :'createdDate' => :'Float',
        :'lastSeenDate' => :'Float',
        :'platform' => :'String',
        :'platformVersion' => :'String',
        :'deviceModel' => :'String',
        :'sdkType' => :'String',
        :'sdkVersion' => :'String'
      }
    end

    # List of attributes with nullable: true
    def self.openapi_nullable
      Set.new([])
    end

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {})
      if (!attributes.is_a?(Hash))
        fail ArgumentError, "The input argument (attributes) must be a hash in `DevCycle::User` initialize method"
      end

      # check to see if the attribute exists and convert string to symbol for hash key
      attributes = attributes.each_with_object({}) { |(k, v), h|
        if (!self.class.attribute_map.key?(k.to_sym))
          fail ArgumentError, "`#{k}` is not a valid attribute in `DevCycle::User`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
        end
        h[k.to_sym] = v
      }

      if attributes.key?(:'user_id')
        self.user_id = attributes[:'user_id']
      end

      if attributes.key?(:'email')
        self.email = attributes[:'email']
      end

      if attributes.key?(:'name')
        self.name = attributes[:'name']
      end

      if attributes.key?(:'language')
        self.language = attributes[:'language']
      end

      if attributes.key?(:'country')
        self.country = attributes[:'country']
      end

      if attributes.key?(:'appVersion')
        self.appVersion = attributes[:'appVersion']
      end

      if attributes.key?(:'appBuild')
        self.appBuild = attributes[:'appBuild']
      end

      if attributes.key?(:'customData')
        self.customData = attributes[:'customData']
      end

      if attributes.key?(:'privateCustomData')
        self.privateCustomData = attributes[:'privateCustomData']
      end

      if attributes.key?(:'deviceModel')
        self.deviceModel = attributes[:'deviceModel']
      end

      # set read-only instance variables
      default_platform_data = PlatformData.new.default
      @sdkType = default_platform_data.sdkType
      @sdkVersion = default_platform_data.sdkVersion
      @platform = default_platform_data.platform
      @platformVersion = default_platform_data.platformVersion
      @createdDate = Time.now.utc.iso8601
      @lastSeenDate = Time.now.utc.iso8601
    end

    # Show invalid properties with the reasons. Usually used together with valid?
    # @return Array for valid properties with the reasons
    def list_invalid_properties
      invalid_properties = Array.new
      if @user_id.nil?
        invalid_properties.push('invalid value for "user_id", user_id cannot be nil.')
      end

      if !@user_id.is_a?(String)
        invalid_properties.push('invalid value for "user_id", user_id must be a string.')
      end

      if !@language.nil? && @language.to_s.length > 2
        invalid_properties.push('invalid value for "language", the character length must be smaller than or equal to 2.')
      end

      if !@country.nil? && @country.to_s.length > 2
        invalid_properties.push('invalid value for "country", the character length must be smaller than or equal to 2.')
      end

      invalid_properties
    end

    # Check to see if the all the properties in the model are valid
    # @return true if the model is valid
    def valid?
      return false if @user_id.nil?
      return false if !@user_id.is_a?(String)
      return false if !@language.nil? && @language.to_s.length > 2
      return false if !@country.nil? && @country.to_s.length > 2
      sdk_type_validator = EnumAttributeValidator.new('String', ["api", "server"])
      return false unless sdk_type_validator.valid?(@sdk_type)
      true
    end

    # Custom attribute writer method with validation
    # @param [Object] language Value to be assigned
    def language=(language)
      if !language.nil? && language.to_s.length > 2
        fail ArgumentError, 'invalid value for "language", the character length must be smaller than or equal to 2.'
      end

      @language = language
    end

    # Custom attribute writer method with validation
    # @param [Object] country Value to be assigned
    def country=(country)
      if !country.nil? && country.to_s.length > 2
        fail ArgumentError, 'invalid value for "country", the character length must be smaller than or equal to 2.'
      end

      @country = country
    end

    # Checks equality by comparing each attribute.
    # @param [Object] Object to be compared
    def ==(o)
      return true if self.equal?(o)
      self.class == o.class &&
        user_id == o.user_id &&
        email == o.email &&
        name == o.name &&
        language == o.language &&
        country == o.country &&
        appVersion == o.appVersion &&
        appBuild == o.appBuild &&
        customData == o.customData &&
        privateCustomData == o.privateCustomData &&
        createdDate == o.createdDate &&
        lastSeenDate == o.lastSeenDate &&
        platform == o.platform &&
        platformVersion == o.platformVersion &&
        deviceModel == o.deviceModel &&
        sdkType == o.sdkType &&
        sdkVersion == o.sdkVersion
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Integer] Hash code
    def hash
      [user_id, email, name, language, country, appVersion, appBuild, customData, privateCustomData, createdDate, lastSeenDate, platform, platformVersion, deviceModel, sdkType, sdkVersion].hash
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def self.build_from_hash(attributes)
      new.build_from_hash(attributes)
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def build_from_hash(attributes)
      return nil unless attributes.is_a?(Hash)
      self.class.openapi_types.each_pair do |key, type|
        if attributes[self.class.attribute_map[key]].nil? && self.class.openapi_nullable.include?(key)
          self.send("#{key}=", nil)
        elsif type =~ /\AArray<(.*)>/i
          # check to ensure the input is an array given that the attribute
          # is documented as an array but the input is not
          if attributes[self.class.attribute_map[key]].is_a?(Array)
            self.send("#{key}=", attributes[self.class.attribute_map[key]].map { |v| _deserialize($1, v) })
          end
        elsif !attributes[self.class.attribute_map[key]].nil?
          self.send("#{key}=", _deserialize(type, attributes[self.class.attribute_map[key]]))
        end
      end

      self
    end

    # Deserializes the data based on type
    # @param string type Data type
    # @param string value Value to be deserialized
    # @return [Object] Deserialized data
    def _deserialize(type, value)
      case type.to_sym
      when :Time
        Time.parse(value)
      when :Date
        Date.parse(value)
      when :String
        value.to_s
      when :Integer
        value.to_i
      when :Float
        value.to_f
      when :Boolean
        if value.to_s =~ /\A(true|t|yes|y|1)\z/i
          true
        else
          false
        end
      when :Object
        # generic object (usually a Hash), return directly
        value
      when /\AArray<(?<inner_type>.+)>\z/
        inner_type = Regexp.last_match[:inner_type]
        value.map { |v| _deserialize(inner_type, v) }
      when /\AHash<(?<k_type>.+?), (?<v_type>.+)>\z/
        k_type = Regexp.last_match[:k_type]
        v_type = Regexp.last_match[:v_type]
        {}.tap do |hash|
          value.each do |k, v|
            hash[_deserialize(k_type, k)] = _deserialize(v_type, v)
          end
        end
      else
        # model
        # models (e.g. Pet) or oneOf
        klass = DevCycle.const_get(type)
        klass.respond_to?(:openapi_one_of) ? klass.build(value) : klass.build_from_hash(value)
      end
    end

    # Returns the string representation of the object
    # @return [String] String presentation of the object
    def to_s
      to_hash.to_s
    end

    # to_body is an alias to to_hash (backward compatibility)
    # @return [Hash] Returns the object in the form of hash
    def to_body
      to_hash
    end

    # Returns the object in the form of hash
    # @return [Hash] Returns the object in the form of hash
    def to_hash
      hash = {}
      self.class.attribute_map.each_pair do |attr, param|
        value = self.send(attr)
        if value.nil?
          is_nullable = self.class.openapi_nullable.include?(attr)
          next if !is_nullable || (is_nullable && !instance_variable_defined?(:"@#{attr}"))
        end

        hash[param] = _to_hash(value)
      end
      hash
    end

    # Outputs non-array value in the form of hash
    # For object, use to_hash. Otherwise, just return the value
    # @param [Object] value Any valid value
    # @return [Hash] Returns the value in the form of hash
    def _to_hash(value)
      if value.is_a?(Array)
        value.compact.map { |v| _to_hash(v) }
      elsif value.is_a?(Hash)
        {}.tap do |hash|
          value.each { |k, v| hash[k] = _to_hash(v) }
        end
      elsif value.respond_to? :to_hash
        value.to_hash
      else
        value
      end
    end

    def to_json
      Oj.dump(to_hash, mode: :json)
    end

    def to_pb_user_data
      pb_user = Proto::DVCUser_PB.new
      pb_user.user_id = @user_id
      pb_user.email = create_nullable_string(@email)
      pb_user.name = create_nullable_string(@name)
      pb_user.language = create_nullable_string(@language)
      pb_user.country = create_nullable_string(@country)
      pb_user.appVersion = create_nullable_string(@appVersion)
      pb_user.appBuild = create_nullable_double(@appBuild)
      pb_user.customData = create_nullable_custom_data(@customData)
      pb_user.privateCustomData = create_nullable_custom_data(@privateCustomData)

      pb_user
    end
  end

  # @deprecated Use `DevCycle::User` instead.
  UserData = User
end
