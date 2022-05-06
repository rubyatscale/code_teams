# typed: true

module Teams
  module Plugins
    class Identity < Plugin
      extend T::Sig
      extend T::Helpers

      IdentityStruct = Struct.new(:name)

      sig { returns(IdentityStruct) }
      def identity
        IdentityStruct.new(
          @team.raw_hash['name']
        )
      end

      sig { override.params(teams: T::Array[Teams::Team]).returns(T::Array[String]) }
      def self.validation_errors(teams)
        errors = T.let([], T::Array[String])

        uniq_set = Set.new
        teams.each do |team|
          for_team = self.for(team)

          if !uniq_set.add?(for_team.identity.name)
            errors << "More than 1 definition for #{for_team.identity.name} found"
          end

          errors << missing_key_error_message(team, 'name') if for_team.identity.name.nil?
        end

        errors
      end
    end
  end
end
