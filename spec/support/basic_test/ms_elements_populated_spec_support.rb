# frozen_string_literal: true

require_relative 'basic_test_instance_setup'

RSpec.shared_context 'ms elements populated setup' do
  include_context 'basic test instance setup'

  let(:metadata_manager) do
    AUPSTestKit::MetadataManager.new('spec/fixtures/metadata.yaml').tap do |manager|
      allow(manager).to receive(:metadata).and_return(minimal_metadata)
    end
  end

  def get_ms_elements_paths(profile_url)
    metadata = metadata_manager.group_metadata_by_profile_url(profile_url)

    metadata&.dig(:must_supports, :elements)&.map { |e| e[:path] } || []
  end

  before { test_instance.metadata_manager = metadata_manager }
end
