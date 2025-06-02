RSpec.describe CodeTeams::Plugin do
  def write_team_yml(extra_data: false)
    write_file('config/teams/my_team.yml', <<~YML.strip)
      name: My Team
      extra_data: #{extra_data}
    YML
  end

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
end
