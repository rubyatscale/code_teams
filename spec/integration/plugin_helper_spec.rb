RSpec.describe CodeTeams::Plugin, 'helper integration' do
  before do
    CodeTeams.bust_caches!
    write_team_yml(extra_data: { foo: 'foo', bar: 'bar' })
  end

  let(:team) { CodeTeams.find('My Team') }

  describe 'helper methods' do
    context 'with a single implicit method' do
      before do
        test_plugin_class = Class.new(described_class) do
          def test_plugin
            data = @team.raw_hash['extra_data']
            Data.define(:foo, :bar).new(data['foo'], data['bar'])
          end
        end

        stub_const('TestPlugin', test_plugin_class)
      end

      it 'adds a helper method to the team' do
        expect(team.test_plugin.foo).to eq('foo')
        expect(team.test_plugin.bar).to eq('bar')
      end

      it 'supports nested data' do
        write_team_yml(extra_data: { foo: { bar: 'bar' } })
        expect(team.test_plugin.foo['bar']).to eq('bar')
      end

      context 'when the data accessor name is overridden' do
        before do
          test_plugin_class = Class.new(described_class) do
            data_accessor_name 'foo'

            def foo
              Data.define(:bar).new('bar')
            end
          end

          stub_const('TestPlugin', test_plugin_class)
        end

        it 'adds the data accessor name to the team' do
          expect(team.foo.bar).to eq('bar')
        end
      end
    end
  end

  specify 'backwards compatibility' do
    test_plugin_class = Class.new(described_class) do
      def test_plugin
        Data.define(:foo).new('foo')
      end
    end

    stub_const('TestPlugin', test_plugin_class)

    expect(TestPlugin.for(team).test_plugin.foo).to eq('foo')
  end
end
