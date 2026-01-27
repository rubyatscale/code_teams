Gem::Specification.new do |spec|
  spec.name          = 'code_teams'
  spec.version       = '1.3.0'
  spec.authors       = ['Gusto Engineers']
  spec.email         = ['dev@gusto.com']
  spec.summary       = 'A low-dependency gem for declaring and querying engineering teams'
  spec.description = 'A low-dependency gem for declaring and querying engineering teams'
  spec.homepage      = 'https://github.com/rubyatscale/code_teams'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/rubyatscale/code_teams'
    spec.metadata['changelog_uri'] = 'https://github.com/rubyatscale/code_teams/releases'
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = Dir['README.md', 'lib/**/*']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.2'

  spec.add_dependency 'sorbet-runtime'
end
