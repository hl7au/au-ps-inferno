# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Must Support elements SHALL be populated if a value is known
  class AUPSSuite100previewAuPsBundleInstanceAuPsCompositionAuthorMustSupportElementsShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support elements SHALL be populated if a value is known'
    description 'Must Support elements SHALL be populated if a value is known'
    id :suite_100preview_au_ps_bundle_instance_au_ps_composition_author_author_ms_elements
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../../metadata.yaml', __dir__))
    end
    
    run do
      
      ms_elements_populated_message("author")
      
    end
    
  end
end
