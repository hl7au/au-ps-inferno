# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

module AUPSTestKit
  # Automatically generated primitive test for Mandatory Must Support elements are correctly populated
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsAuPsCompositionMustSupportConformanceMandatoryMustSupportElementsAreCorrectlyPopulated < BasicTest
    title 'Mandatory Must Support elements are correctly populated'
    description 'Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share.'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_must_support_conformance_composition_mandatory_ms_populated

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end

    run do
      validate_populated_elements_in_composition(%w[author date status subject title type])
    end
  end
end
