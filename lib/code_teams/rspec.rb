# frozen_string_literal: true
#
# typed: false

require 'securerandom'
require 'code_teams/testing'

CodeTeams::Testing.enable!

module CodeTeams
  module RSpecHelpers
    def code_team_with_config(team_config = {})
      team_config = team_config.dup
      team_config[:name] ||= "Fake Team #{SecureRandom.hex(4)}"
      CodeTeams::Testing.create_code_team(team_config)
    end
  end
end

if defined?(RSpec)
  RSpec.configure do |config|
    config.around do |example|
      example.run
      # Bust caches because plugins may hang onto stale data between examples.
      if CodeTeams::Testing.code_teams.any?
        CodeTeams.bust_caches!
        CodeTeams::Testing.reset!
      end
    end
  end
end
