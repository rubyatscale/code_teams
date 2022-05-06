RSpec.describe 'Teams' do
  let(:team_yml) do
    <<~YML.strip
      name: My Team
    YML
  end

  before do
    write_file('config/teams/my_team.yml', team_yml)
    Teams.bust_caches!
    allow(Teams::Plugin).to receive(:registry).and_return({})
  end

  describe '.all' do
    it 'correctly parses the team files' do
      expect(Teams.all.count).to eq 1
      team = Teams.all.first
      expect(team.name).to eq 'My Team'
      expect(team.raw_hash['name']).to eq 'My Team'
      expect(team.config_yml).to eq 'config/teams/my_team.yml'
    end

    context 'team YML has syntax errors' do
      let(:team_yml) do
        <<~YML.strip
          name =>>>asdfaf!!@#!@#@!syntax error My Team
          asdfsa: asdfs
        YML
      end

      it 'spits out a helpful error message' do
        expect { Teams.all }.to raise_error do |e|
          expect(e).to be_a Teams::IncorrectPublicApiUsageError
          expect(e.message).to eq('The YML in config/teams/my_team.yml has a syntax error!')
        end
      end
    end
  end

  describe 'validation_errors' do
    subject(:validation_errors) { Teams.validation_errors(Teams.all) }

    context 'there is one definition for all teams' do
      it 'has no errors' do
        expect(validation_errors).to be_empty
      end
    end

    context 'there are multiple definitions for the same team' do
      before do
        write_file('config/teams/my_other_team.yml', team_yml)
      end

      it 'registers the team file as invalid' do
        expect(validation_errors).to match_array(
          [
            'More than 1 definition for My Team found',
          ]
        )
      end
    end
  end

  describe '==' do
    it 'handles nil correctly' do
      expect(Teams.all.first == nil).to eq false # rubocop:disable Style/NilComparison
      expect(nil == Teams.all.first).to eq false
    end
  end
end
