require 'code_teams/testing'

CodeTeams::Testing.enable!

RSpec.describe CodeTeams::Testing do
  describe '.create_code_team' do
    it 'adds the team to CodeTeams.all and CodeTeams.find' do
      team = described_class.create_code_team({ name: 'Temp Team', extra_data: { foo: { bar: 1 } } })

      expect(CodeTeams.all).to include(team)
      expect(CodeTeams.find('Temp Team')).to eq(team)
      expect(team.raw_hash.dig('extra_data', 'foo', 'bar')).to eq(1)
    end

    it 'does not let a fake team inherit a real same-named team\'s cached plugin data' do
      test_plugin_class = Class.new(CodeTeams::Plugin) do
        def test_plugin
          Data.define(:source).new(@team.raw_hash['extra_data']['source'])
        end
      end
      stub_const('TestPlugin', test_plugin_class)
      CodeTeams.bust_caches!
      write_team_yml(extra_data: { 'source' => 'real' })

      # Reading the real team caches its plugin instance under the name 'My Team'.
      expect(CodeTeams.find('My Team').test_plugin.source).to eq('real')

      fake = described_class.create_code_team({ name: 'My Team', extra_data: { 'source' => 'fake' } })

      expect(fake.test_plugin.source).to eq('fake')
    end
  end
end
