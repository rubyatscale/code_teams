module CodeTeams
  module Utils
    module_function

    def underscore(string)
      string.gsub('::', '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
    end

    def demodulize(string)
      string.split('::').last
    end

    def deep_stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) do |(k, v), acc|
          acc[k.to_s] = deep_stringify_keys(v)
        end
      when Array
        value.map { |v| deep_stringify_keys(v) }
      else
        value
      end
    end
  end
end
