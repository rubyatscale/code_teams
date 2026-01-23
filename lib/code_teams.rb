# frozen_string_literal: true

# typed: strict

require 'yaml'
require 'pathname'
require 'sorbet-runtime'
require 'code_teams/plugin'
require 'code_teams/plugins/identity'
require 'code_teams/utils'

module CodeTeams
  extend T::Sig

  class IncorrectPublicApiUsageError < StandardError; end

  UNKNOWN_TEAM_STRING = 'Unknown Team'
  @plugins_registered = T.let(false, T::Boolean)

  sig { returns(T::Array[Team]) }
  def self.all
    @all = T.let(@all, T.nilable(T::Array[Team]))
    @all ||= for_directory('config/teams')
  end

  sig { params(name: String).returns(T.nilable(Team)) }
  def self.find(name)
    @index_by_name = T.let(@index_by_name, T.nilable(T::Hash[String, CodeTeams::Team]))
    @index_by_name ||= begin
      result = {}
      all.each { |t| result[t.name] = t }
      result
    end

    @index_by_name[name]
  end

  sig { params(dir: String).returns(T::Array[Team]) }
  def self.for_directory(dir)
    unless @plugins_registered
      Team.register_plugins
      @plugins_registered = true
    end

    Pathname.new(dir).glob('**/*.yml').map do |path|
      Team.from_yml(path.to_s)
    rescue Psych::SyntaxError
      raise IncorrectPublicApiUsageError, "The YML in #{path} has a syntax error!"
    end
  end

  sig { params(teams: T::Array[Team]).returns(T::Array[String]) }
  def self.validation_errors(teams)
    Plugin.all_plugins.flat_map do |plugin|
      plugin.validation_errors(teams)
    end
  end

  sig { params(string: String).returns(String) }
  def self.tag_value_for(string)
    string.tr('&', ' ').gsub(/\s+/, '_').downcase
  end

  # Generally, you should not ever need to do this, because once your ruby process loads, cached content should not change.
  # Namely, the YML files that are the source of truth for teams should not change, so we should not need to look at the YMLs again to verify.
  # The primary reason this is helpful is for clients of CodeTeams who want to test their code, and each test context has different set of teams
  sig { void }
  def self.bust_caches!
    @plugins_registered = false
    Plugin.bust_caches!
    @all = nil
    @index_by_name = nil
  end

  class Team
    extend T::Sig

    sig { params(config_yml: String).returns(Team) }
    def self.from_yml(config_yml)
      hash = YAML.load_file(config_yml)

      new(
        config_yml: config_yml,
        raw_hash: hash
      )
    end

    sig { params(raw_hash: T::Hash[String, T.untyped]).returns(Team) }
    def self.from_hash(raw_hash)
      new(
        config_yml: nil,
        raw_hash: raw_hash
      )
    end

    sig { void }
    def self.register_plugins
      Plugin.all_plugins.each do |plugin|
        # e.g., def github (on Team)
        define_method(plugin.data_accessor_name) do
          # e.g., MyGithubPlugin.for(team).github
          plugin.for(T.cast(self, Team)).public_send(plugin.data_accessor_name)
        end
      end
    end

    sig { returns(T::Hash[String, T.untyped]) }
    attr_reader :raw_hash

    sig { returns(T.nilable(String)) }
    attr_reader :config_yml

    sig do
      params(
        config_yml: T.nilable(String),
        raw_hash: T::Hash[String, T.untyped]
      ).void
    end
    def initialize(config_yml:, raw_hash:)
      @config_yml = config_yml
      @raw_hash = raw_hash
    end

    sig { returns(String) }
    def name
      Plugins::Identity.for(self).identity.name
    end

    sig { returns(String) }
    def to_tag
      CodeTeams.tag_value_for(name)
    end

    sig { params(other: Object).returns(T::Boolean) }
    def ==(other)
      if other.is_a?(CodeTeams::Team)
        name == other.name
      else
        false
      end
    end

    alias eql? ==

    sig { returns(Integer) }
    def hash
      name.hash
    end
  end
end
