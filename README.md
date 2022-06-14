# CodeTeams

This gem is a simple, low-dependency, plugin-based manager for teams within a codebase.

## Usage

To use `code_teams`, add YML files in `config/teams` that start with structure:
`config/teams/my_team.yml`
```yml
name: My Team
```

`code_teams` leverages a plugin system because every organization's team practices are different. Say your organization uses GitHub and wants to ensure every team YML files has a GitHub owner. To do this, you create a plugin:

```ruby
class MyGithubPlugin < CodeTeams::Plugin
  extend T::Sig
  extend T::Helpers

  GithubStruct = Struct.new(:team, :members)

  sig { returns(GithubStruct) }
  def github
    raw_github = @team.raw_hash['github'] || {}

    GithubStruct.new(
      raw_github['team'],
      raw_github['members'] || []
    )
  end

  def member?(user)
    members = github.members
    return false unless members

    members.include?(user)
  end

  sig { override.params(teams: T::Array[CodeTeams::Team]).returns(T::Array[String]) }
  def self.validation_errors(teams)
    errors = T.let([], T::Array[String])

    teams.each do |team|
      errors << missing_key_error_message(team, 'github.team') if self.for(team).github.team.nil?
    end

    errors
  end
end
```

After adding the proper GitHub information to the team YML:
```yml
name: My Team
github:
  team: '@org/my-team
  members:
    - member1
    - member2
```

1) You can now use the following API to get GitHub information about that team:
```ruby
team = CodeTeams.find('My Team')
MyGithubPlugin.for(team).github
```
2) Running team validations (see below) will ensure all teams have a GitHub team specified

Your plugins can be as simple or as complex as you want. Here are some other things we use plugins for:
- Identifying which teams own which feature flags
- Mapping teams to specific portions of the code through `code_ownership`
- Allowing teams to protect certain files and require approval on modification of certain files
- Specifying owned dependencies (ruby gems, javascript packages, and more)
- Specifying how to get in touch with the team via slack (their channel and handle)

## Configuration
You'll want to ensure that all teams are valid in your CI environment. We recommend running code like this in CI:
```ruby
require 'code_teams'
errors = ::CodeTeams.validation_errors(::CodeTeams.all)
if errors.any?
  abort <<~ERROR
    Team validation failed with the following errors:
    #{errors.join("\n")}
  ERROR
end
```

## Contributing

Bug reports and pull requests are welcome!

