# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

module CompositionSectionCheckMsPassSpecSupport
  SECTION_CODES = ['11450-4'].freeze

  def evaluate_bundle(test_instance, bundle_fixture_path)
    bundle_json = File.read(bundle_fixture_path)
    test_instance.scratch_bundle = FHIR::Bundle.new(JSON.parse(bundle_json))

    profiles = test_instance.send(:sections_profiles, SECTION_CODES)
    resources = test_instance.send(:resources_to_check_ms, SECTION_CODES)
    results = test_instance.send(:check_resources_against_profiles, profiles, resources)
    pass = test_instance.send(:composition_section_check_ms_pass?, SECTION_CODES)

    [results, pass]
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe(
  AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule
) do
  include CompositionSectionCheckMsPassSpecSupport

  let(:test_class) do
    Class.new do
      # TODO: Maybe we need to use a test class without include. Why we include at all?
      include(
        AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule
      )

      attr_accessor :metadata_manager
      attr_accessor :scratch_bundle

      def add_message(_level, _message); end
    end
  end

  let(:test_instance) { test_class.new }
  let(:metadata_manager) { AUPSTestKit::MetadataManager.new('spec/fixtures/metadata.yaml') }

  before do
    test_instance.metadata_manager = metadata_manager
  end

  it 'returns false for a minimal error bundle' do
    results, pass = evaluate_bundle(test_instance, 'spec/fixtures/resources/bundle_ms_error_min.json')
    expect(results).to include('error')
    expect(pass).to be(false)
  end

  it 'returns true for a minimal warning bundle' do
    results, pass = evaluate_bundle(test_instance, 'spec/fixtures/resources/bundle_ms_warning_min.json')
    expect(results).to include('warning')
    expect(results).not_to include('error')
    expect(pass).to be(true)
  end

  it 'returns true for a minimal bundle with a valid condition' do
    results, pass = evaluate_bundle(test_instance, 'spec/fixtures/resources/bundle_ms_info_min.json')
    expect(results).not_to include('error')
    expect(results).to include('warning')
    expect(pass).to be(true)
  end
end
# rubocop:enable Metrics/BlockLength
