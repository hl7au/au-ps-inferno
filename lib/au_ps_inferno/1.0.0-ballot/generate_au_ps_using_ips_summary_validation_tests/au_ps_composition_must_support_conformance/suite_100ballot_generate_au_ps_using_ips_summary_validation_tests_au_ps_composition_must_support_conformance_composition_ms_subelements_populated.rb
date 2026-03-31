# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-elements of a complex element are correctly populated
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionMustSupportConformanceMustSupportSubelementsOfAComplexElementAreCorrectlyPopulated < BasicTest
    title 'Must Support sub-elements of a complex element are correctly populated'
    description 'Must Support sub-elements of a complex element SHALL be correctly populated if a value is known'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_must_support_conformance_composition_ms_subelements_populated
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-ballot/metadata.yaml', __dir__))
    end
    
    run do
      
      validate_populated_sub_elements_in_composition(["attester.mode", "subject.reference"], ["attester.party", "attester.time"])
      
    end
    
  end
end
