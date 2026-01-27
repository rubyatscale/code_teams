# frozen_string_literal: true
#
# typed: strict

require 'securerandom'
require 'code_teams'
require 'code_teams/testing/rspec_helpers'

module CodeTeams
  # Utilities for tests that need a controlled set of teams without writing YML
  # files to disk.
  #
  # Opt-in by requiring `code_teams/testing`.
  module Testing
    extend T::Sig

    THREAD_KEY = T.let(:__code_teams_collection, Symbol)
    @enabled = T.let(false, T::Boolean)

    sig { void }
    def self.enable!
      return if @enabled

      CodeTeams.prepend(CodeTeamsExtension)
      @enabled = true

      return unless defined?(RSpec)

      T.unsafe(RSpec).configure do |config|
        config.include CodeTeams::Testing::RSpecHelpers

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

    sig { params(attributes: T::Hash[Symbol, T.untyped]).returns(CodeTeams::Team) }
    def self.create_code_team(attributes)
      attributes = attributes.dup
      attributes[:name] ||= "Fake Team #{SecureRandom.hex(4)}"

      code_team = CodeTeams::Team.new(
        config_yml: 'tmp/fake_config.yml',
        raw_hash: Utils.deep_stringify_keys(attributes)
      )

      code_teams << code_team
      code_team
    end

    sig { returns(T::Array[CodeTeams::Team]) }
    def self.code_teams
      existing = Thread.current[THREAD_KEY]
      return existing if existing.is_a?(Array)

      Thread.current[THREAD_KEY] = []
      T.cast(Thread.current[THREAD_KEY], T::Array[CodeTeams::Team])
    end

    sig { void }
    def self.reset!
      Thread.current[THREAD_KEY] = []
    end

    module CodeTeamsExtension
      extend T::Sig

      sig { params(base: Module).void }
      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end

      module ClassMethods
        extend T::Sig

        sig { returns(T::Array[CodeTeams::Team]) }
        def all
          CodeTeams::Testing.code_teams + super
        end

        sig { params(name: String).returns(T.nilable(CodeTeams::Team)) }
        def find(name)
          CodeTeams::Testing.code_teams.find { |t| t.name == name } || super
        end
      end
    end
  end
end
