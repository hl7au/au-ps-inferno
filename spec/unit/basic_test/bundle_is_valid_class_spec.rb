# frozen_string_literal: true

require 'fhir_models'
require 'json'

require_relative '../../../lib/au_ps_inferno/utils/bundle_is_valid_class'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

BUNDLE_IS_VALID_FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze

RSpec.describe AUPSTestKit::BundleIsValidClass do
  include_context 'when testing a runnable'

  let(:suite_id) { 'bundle_is_valid_class_test_suite' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'bundle_is_valid_class_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?('bundle_is_valid_class_test_suite')
  end

  def create_test(test_id, superclass)
    klass = Class.new(superclass) do
      id test_id
      define_method(:metadata_manager) do
        @metadata_manager ||= AUPSTestKit::CompositionMetadataManager.new(BUNDLE_IS_VALID_FIXTURE_METADATA_PATH)
      end
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  def build_bundle
    FHIR::Bundle.new(resourceType: 'Bundle', type: 'document', timestamp: '2025-01-01T00:00:00Z')
  end

  it 'omits when no Bundle was acquired' do
    test = create_test('bundle_is_valid_class_no_bundle_test', described_class)
    result = run(test, {}, { validate_against: ['au_ps_bundle'] })

    expect(result.result).to eq('omit')
    expect(result.result_message).to match(/No AU PS Bundle was loaded by this test group/)
  end

  it 'omits when the acquisition test did not select AU PS Bundle validation' do
    test = create_test('bundle_is_valid_class_not_selected_test', described_class)
    result = run(test, {}, { bundle_ips_resource: build_bundle, validate_against: ['ips_bundle'] })

    expect(result.result).to eq('omit')
    expect(result.result_message).to match(/AU PS Bundle.*Validation.*is not selected/)
  end
end
