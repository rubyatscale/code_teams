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
  end
end
