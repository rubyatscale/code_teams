Gem::Specification.new do |spec|
  spec.name          = 'bigrails-teams'
  spec.version       = '0.1.0'
  spec.authors       = ['Gusto Engineers']
  spec.email         = ['dev@gusto.com']
  spec.summary       = 'A low-dependency gem for declaring and querying engineering teams'
  spec.description = 'A low-dependency gem for declaring and querying engineering teams'
  spec.homepage      = 'https://github.com/bigrails/teams'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/bigrails/teams'
    spec.metadata['changelog_uri'] = 'https://github.com/bigrails/teams/releases'
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = Dir['README.md', 'sorbet/**/*', 'lib/**/*']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'sorbet-runtime'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'sorbet'
end
