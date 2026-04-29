# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/generator/generator'

RSpec.describe Generator do
  describe '#suite_primitive_config' do
    it 'uses full IG version for validator package reference' do
      generator = described_class.allocate
      generator.instance_variable_set(:@suite_version, '1.0.0-ballot')

      config = generator.send(
        :suite_primitive_config,
        'AUPSSuite100ballot',
        :suite_100ballot,
        '100ballot',
        []
      )

      expect(config[:suite_version]).to eq('1.0.0-ballot')
      expect(config[:id]).to eq(:suite_100ballot)
      expect(config[:output_file_path]).to eq('lib/au_ps_inferno/1.0.0-ballot/100ballot_suite.rb')
    end
  end
end
