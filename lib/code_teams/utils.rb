module CodeTeams
  class Utils
    def self.underscore(string)
      string.gsub('::', '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
    end

    def self.demodulize(string)
      string.split('::').last
    end
  end
end
