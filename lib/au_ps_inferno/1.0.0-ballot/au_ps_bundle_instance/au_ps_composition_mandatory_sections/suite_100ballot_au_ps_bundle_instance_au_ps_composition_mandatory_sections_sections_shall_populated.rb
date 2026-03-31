# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition Mandatory Sections are correctly populated
  class AUPSSuite100ballotAuPsBundleInstanceAuPsCompositionMandatorySectionsAuPsCompositionMandatorySectionsAreCorrectlyPopulated < BasicTest
    title 'AU PS Composition Mandatory Sections are correctly populated'
    description 'Mandatory section SHALL be correctly populated if a value is known'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_composition_mandatory_sections_sections_shall_populated
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-ballot/metadata.yaml', __dir__))
    end
    
    run do
      
      validate_populated_sections_in_bundle(["11450-4", "48765-2", "10160-0"], ["title", "code", "text"])
      
    end
    
  end
end
