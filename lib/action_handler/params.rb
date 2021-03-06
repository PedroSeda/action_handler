module ActionHandler
  class Params
    def self.build(hash = {}, sources: [])
      sources.reduce(self.new) do |params, source|
        params.merge(source.parametrize(hash))
      end
    end

    def initialize(hash = {})
      @hash = hash.with_indifferent_access
    end

    def [](key)
      convert_values_to_hashes(key, @hash[key])
    end

    def dig(*keys)
      convert_values_to_hashes(keys.first, @hash[keys.first])
      @hash.dig(*keys)
    end

    def slice(*keys)
      keys.each { |key| convert_values_to_hashes(key, @hash[key]) }
      @hash.slice(*keys)
    end

    def merge(params)
      self.class.new(@hash.merge(params.to_h))
    end

    def to_h
      @hash
    end

    private

    def convert_values_to_hashes(key, value)
      converted = convert_value_to_hash(value)
      @hash[key] = converted unless converted.equal?(value)
      converted
    end

    def convert_value_to_hash(value)
      case value
      when Array
        value.map { |v| convert_value_to_hash(v) }
      when Hash
        value
          .transform_values { |v| convert_value_to_hash(v) }
          .with_indifferent_access
      when String
        parse_string(value)
      else
        value
      end
    end

    def parse_string(value)
      convert_value_to_hash(JSON.parse(value))
    rescue JSON::ParserError
      value
    end
  end
end
