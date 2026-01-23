require 'code_teams/rspec'

RSpec.describe CodeTeams::RSpecHelpers do
  include described_class

  it 'exposes code_team_with_config and makes the team discoverable' do
    code_team_with_config(name: 'RSpec Team')

    expect(CodeTeams.find('RSpec Team')).not_to be_nil
  end

  it 'cleans up testing teams between examples' do
    expect(CodeTeams::Testing.code_teams).to be_empty
    expect(CodeTeams.find('RSpec Team')).to be_nil
  end
end
