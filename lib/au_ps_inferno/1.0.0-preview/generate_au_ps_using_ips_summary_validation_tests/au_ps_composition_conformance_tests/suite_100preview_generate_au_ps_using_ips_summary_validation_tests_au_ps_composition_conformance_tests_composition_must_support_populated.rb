# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Composition Must Support elements are correctly populated
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionConformanceTestsCompositionMustSupportElementsAreCorrectlyPopulated < BasicTest
    title 'Composition Must Support elements are correctly populated'
    description 'Composition Must Support elements — mandatory and optional elements, sub-elements of complex elements, and the careProvisioningEvent slice — SHALL be populated if a value is known and allowed to be shared.'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_conformance_tests_composition_must_support_populated
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
    run do
      
      validate_composition_must_support(["author", "date", "status", "subject", "title", "type"], ["attester", "custodian", "identifier", "text", "event"], ["attester.mode", "subject.reference"], ["attester.party", "attester.time"], [{:path=>"event", :sliceName=>"careProvisioningEvent", :min=>0, :max=>"1", :mustSupport=>true, :mandatory_ms_sub_elements=>["period"], :optional_ms_sub_elements=>["code"]}])
      
    end
    
  end
end
