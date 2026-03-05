# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this project is

`code_teams` is a low-dependency, plugin-based Ruby gem for declaring and querying engineering teams within a codebase. Teams are defined in `config/teams/*.yml` files, and plugins extend validation and querying behavior per organization.

## Commands

```bash
bundle install

# Run all tests (RSpec)
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/path/to/spec.rb

# Lint
bundle exec rubocop
bundle exec rubocop -a  # auto-correct

# Type checking (Sorbet)
bundle exec srb tc
```

## Architecture

- `lib/code_teams.rb` — public API: `CodeTeams.all`, `CodeTeams.find`, team plugin registration
- `lib/code_teams/` — `Team` struct, YAML parsing, plugin interface, and built-in plugins
- `spec/` — RSpec tests; `spec/fixtures/` holds sample `config/teams/` directories
