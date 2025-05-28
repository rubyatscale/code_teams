RSpec.describe CodeTeams::Plugin, 'helper integration' do
  before do
    CodeTeams.bust_caches!
    write_team_yml(extra_data: { foo: 'foo', bar: 'bar' })
  end

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
        team = CodeTeams.find('My Team')

        expect(team.test_plugin.foo).to eq('foo')
        expect(team.test_plugin.bar).to eq('bar')
      end

      it 'supports nested data' do
        write_team_yml(extra_data: { foo: { bar: 'bar' } })
        team = CodeTeams.find('My Team')
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
          team = CodeTeams.find('My Team')

          expect(team.foo.bar).to eq('bar')
        end
      end
    end

    context 'with other public methods' do
      before do
        test_plugin_class = Class.new(described_class) do
          def test_plugin
            Data.define(:foo).new('foo')
          end

          def other_method1
            'other1'
          end

          def other_method2
            'other2'
          end
        end

        stub_const('TestPlugin', test_plugin_class)
      end

      it 'adds the other methods to the team' do
        skip 'TODO: cannot support in this version'
        team = CodeTeams.find('My Team')

        expect(team.test_plugin.foo).to eq('foo')
        expect(team.test_plugin.other_method1).to eq('other1')
        expect(team.test_plugin.other_method2).to eq('other2')
      end
    end
  end
end
