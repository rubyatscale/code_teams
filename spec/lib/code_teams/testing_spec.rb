require 'code_teams/testing'

CodeTeams::Testing.enable!

RSpec.describe CodeTeams::Testing do
  before do
    CodeTeams.bust_caches!
    described_class.reset!
  end

  after do
    CodeTeams.bust_caches!
    described_class.reset!
  end

  describe '.create_code_team' do
    it 'adds the team to CodeTeams.all and CodeTeams.find' do
      team = described_class.create_code_team({ name: 'Temp Team', extra_data: { foo: { bar: 1 } } })

      expect(CodeTeams.all).to include(team)
      expect(CodeTeams.find('Temp Team')).to eq(team)
      expect(team.raw_hash.dig('extra_data', 'foo', 'bar')).to eq(1)
    end
  end
end
