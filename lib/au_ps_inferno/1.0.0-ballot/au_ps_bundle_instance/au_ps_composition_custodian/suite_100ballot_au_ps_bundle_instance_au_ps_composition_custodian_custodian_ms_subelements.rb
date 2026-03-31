# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-element SHALL be populated if a value is known
  class AUPSSuite100ballotAuPsBundleInstanceAuPsCompositionCustodianMustSupportSubelementShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support sub-element SHALL be populated if a value is known'
    description 'Must Support sub-element SHALL be populated if a value is known'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_composition_custodian_custodian_ms_subelements
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-ballot/metadata.yaml', __dir__))
    end
    
    run do
      
      test_composition_custodian_ms_subelements
      
    end
    
  end
end
