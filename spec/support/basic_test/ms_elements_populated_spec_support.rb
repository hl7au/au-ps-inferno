# frozen_string_literal: true

RSpec.shared_context 'ms elements populated setup' do
  let(:test_class) do
    Class.new(AUPSTestKit::BasicTest) do
      attr_accessor :metadata_manager
    end
  end
  let(:test_instance) { test_class.new }

  let(:metadata_manager) do
    AUPSTestKit::MetadataManager.new('spec/fixtures/metadata.yaml').tap do |manager|
      allow(manager).to receive(:metadata).and_return(minimal_metadata)
    end
  end

  def get_ms_elements_paths(resource_type)
    metadata_manager.group_metadata_by_resource_type(resource_type)[:must_supports][:elements].map do |e|
      e[:path]
    end
  end

  before { test_instance.metadata_manager = metadata_manager }
end
