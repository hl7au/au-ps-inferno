# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/utils/metadata_manager'

RSpec.describe AUPSTestKit::MetadataManager do
  subject(:metadata_manager) { described_class.new(File.expand_path('../fixtures/metadata.yaml', __dir__)) }

  describe '#ig_version' do
    it 'strips the leading v from the raw ig_version metadata field' do
      expect(metadata_manager.ig_version).to eq('1.0.0-ballot')
    end
  end
end
