module TestNamespace; end

RSpec.describe CodeTeams::Plugin do
  describe '.bust_caches!' do
    it 'clears all plugins team registries ensuring cached configs are purged' do
      test_plugin_class = Class.new(described_class) do
        def extra_data
          @team.raw_hash['extra_data']
        end
      end
      stub_const('TestNamespace::TestPlugin', test_plugin_class)

      CodeTeams.bust_caches!
      write_team_yml(extra_data: true)
      team = CodeTeams.find('My Team')
      expect(TestNamespace::TestPlugin.for(team).extra_data).to be(true)
      write_team_yml(extra_data: false)
      CodeTeams.bust_caches!
      team = CodeTeams.find('My Team')
      expect(TestNamespace::TestPlugin.for(team).extra_data).to be(false)
    end
  end

  describe '.data_accessor_name' do
    it 'returns the underscore version of the plugin name' do
      test_plugin_class = Class.new(described_class)
      stub_const('TestNamespace::TestPlugin', test_plugin_class)

      expect(TestNamespace::TestPlugin.data_accessor_name).to eq('test_plugin')
    end

    it 'can be overridden by a subclass' do
      test_plugin_class = Class.new(described_class) do
        data_accessor_name 'foo'
      end
      stub_const('TestNamespace::TestPlugin', test_plugin_class)

      expect(TestNamespace::TestPlugin.data_accessor_name).to eq('foo')
    end
  end
end
