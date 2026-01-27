# frozen_string_literal: true
#
# typed: false

require 'securerandom'
require 'code_teams/testing'

module CodeTeams
  module Testing
    module RSpecHelpers
      def code_team_with_config(team_config = {})
        team_config = team_config.dup
        team_config[:name] ||= "Fake Team #{SecureRandom.hex(4)}"
        CodeTeams::Testing.create_code_team(team_config)
      end
    end
  end
end
