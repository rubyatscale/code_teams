RSpec.describe CodeTeams::Plugin do
  before do
    CodeTeams.bust_caches!

    test_plugin_class = Class.new(described_class) do
      def extra_data
        @team.raw_hash['extra_data']
      end
    end
    stub_const('TestPlugin', test_plugin_class)
  end

  describe '.bust_caches!' do
    it 'clears all plugins team registries ensuring cached configs are purged' do
      write_team_yml(extra_data: true)
      team = CodeTeams.find('My Team')
      expect(TestPlugin.for(team).extra_data).to be(true)
      write_team_yml(extra_data: false)
      CodeTeams.bust_caches!
      team = CodeTeams.find('My Team')
      expect(TestPlugin.for(team).extra_data).to be(false)
    end
  end

  describe '.root_key' do
    it 'returns the underscore version of the plugin name' do
      test_plugin_class = Class.new(described_class)
      stub_const('FooNamespace::TestPlugin', test_plugin_class)

      expect(FooNamespace::TestPlugin.root_key).to eq('test_plugin')
    end

    it 'can be overridden by a subclass' do
      skip 'TODO: implement'
    end
  end
end
