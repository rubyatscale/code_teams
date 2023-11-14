# typed: strict

module CodeTeams
  # Plugins allow a client to add validation on custom keys in the team YML.
  # For now, only a single plugin is allowed to manage validation on a top-level key.
  # In the future we can think of allowing plugins to be gracefully merged with each other.
  class Plugin
    extend T::Helpers
    extend T::Sig

    abstract!

    sig { params(team: Team).void }
    def initialize(team)
      @team = team
    end

    sig { params(base: T.untyped).void }
    def self.inherited(base) # rubocop:disable Lint/MissingSuper
      all_plugins << T.cast(base, T.class_of(Plugin))
    end

    sig { returns(T::Array[T.class_of(Plugin)]) }
    def self.all_plugins
      @all_plugins ||= T.let(@all_plugins, T.nilable(T::Array[T.class_of(Plugin)]))
      @all_plugins ||= []
      @all_plugins
    end

    sig { params(teams: T::Array[Team]).returns(T::Array[String]) }
    def self.validation_errors(teams)
      []
    end

    sig { params(team: Team).returns(T.attached_class) }
    def self.for(team)
      register_team(team)
    end

    sig { params(team: Team, key: String).returns(String) }
    def self.missing_key_error_message(team, key)
      "#{team.name} is missing required key `#{key}`"
    end

    sig { returns(T::Hash[T.nilable(String), T::Hash[Class, Plugin]]) }
    def self.registry
      @registry ||= T.let(@registry, T.nilable(T::Hash[String, T::Hash[Class, Plugin]]))
      @registry ||= {}
      @registry
    end

    sig { params(team: Team).returns(T.attached_class) }
    def self.register_team(team)
      # We pull from the hash since `team.name` uses the registry
      team_name = team.raw_hash['name']

      registry[team_name] ||= {}
      registry_for_team = registry[team_name] || {}
      registry[team_name] ||= {}
      registry_for_team[self] ||= new(team)
      T.unsafe(registry_for_team[self])
    end

    sig { void }
    def self.bust_caches!
      all_plugins.each(&:clear_team_registry!)
    end

    sig { void }
    def self.clear_team_registry!
      @registry = nil
    end

    private_class_method :registry
    private_class_method :register_team
  end
end
