# frozen_string_literal: true
#
# typed: strict

require 'securerandom'
require 'code_teams'

module CodeTeams
  # Utilities for tests that need a controlled set of teams without writing YML
  # files to disk.
  #
  # Opt-in by requiring `code_teams/testing`.
  module Testing
    extend T::Sig

    THREAD_KEY = T.let(:__code_teams_collection, Symbol)

    sig { params(attributes: T::Hash[T.untyped, T.untyped]).returns(CodeTeams::Team) }
    def self.create_code_team(attributes)
      attributes = attributes.dup
      attributes[:name] ||= "Fake Team #{SecureRandom.hex(4)}"

      code_team = CodeTeams::Team.new(
        config_yml: 'tmp/fake_config.yml',
        raw_hash: T.cast(deep_stringify_keys(attributes), T::Hash[T.untyped, T.untyped])
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

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.deep_stringify_keys(value)
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
    private_class_method :deep_stringify_keys

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

CodeTeams.prepend(CodeTeams::Testing::CodeTeamsExtension)
