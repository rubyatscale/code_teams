RSpec.describe CodeTeams::Utils do
  describe '.underscore' do
    # These cases pin the exact behavior of the acronym-splitting step so that the
    # linear-time zero-width rewrite stays equivalent to the original
    # `/([A-Z]+)([A-Z][a-z])/` pattern.
    {
      '' => '',
      'A' => 'a',
      'Ab' => 'ab',
      'AAb' => 'a_ab',
      'AABb' => 'aa_bb',
      'ABCd' => 'ab_cd',
      'HTMLParser' => 'html_parser',
      'ALLCAPS' => 'allcaps',
      'allLower' => 'all_lower',
      'aABc' => 'a_a_bc',
      'ABCdEFg' => 'ab_cd_e_fg',
      'A1b' => 'a1b',
      'ABC1de' => 'abc1de',
      'X9Yz' => 'x9_yz',
      'HTTPResponse2XX' => 'http_response2_xx',
      'Foo::BarBaz' => 'foo/bar_baz',
      'Foo::HTMLParser::XMLNode' => 'foo/html_parser/xml_node',
      'my-Team-Name' => 'my_team_name'
    }.each do |input, expected|
      it "converts #{input.inspect} to #{expected.inspect}" do
        expect(described_class.underscore(input)).to eq(expected)
      end
    end
  end
end
