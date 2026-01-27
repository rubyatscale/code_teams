# frozen_string_literal: true
#
# typed: strict

module CodeTeams
  module Utils
    extend T::Sig

    module_function

    sig { params(string: String).returns(String) }
    def underscore(string)
      string.gsub('::', '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
    end

    sig { params(string: String).returns(String) }
    def demodulize(string)
      T.must(string.split('::').last)
    end

    # Recursively converts symbol keys to strings. Top-level input should be a Hash.
    sig { params(value: T.untyped).returns(T.untyped) }
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
