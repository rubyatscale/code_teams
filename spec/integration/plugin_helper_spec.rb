RSpec.describe CodeTeams::Plugin, 'helper integration' do
  def write_team_yml(extra_data: false)
    write_file('config/teams/my_team.yml', <<~YML.strip)
      name: My Team
      extra_data: #{extra_data}
    YML
  end

  before do
    CodeTeams.bust_caches!

    test_plugin_class = Class.new(described_class) do
      MyStruct = Data.define(:foo, :bar)

      def test_plugin
        data = @team.raw_hash['extra_data']
        MyStruct.new(data['foo'], data['bar'])
      end
    end

    stub_const('TestPlugin', test_plugin_class)
  end

  describe 'helper methods' do
    it 'adds a helper method to the team' do
      write_team_yml(extra_data: { foo: 'foo', bar: 'bar' })

      team = CodeTeams.find('My Team')

      expect(team.test_plugin.foo).to eq('foo')
      expect(team.test_plugin.bar).to eq('bar')
    end
  end
end
