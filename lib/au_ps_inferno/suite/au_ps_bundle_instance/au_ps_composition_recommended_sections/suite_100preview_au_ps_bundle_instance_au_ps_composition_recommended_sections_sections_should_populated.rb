# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition recommended sections are correctly populated
  class AUPSSuite100previewAuPsBundleInstanceAuPsCompositionRecommendedSectionsAuPsCompositionRecommendedSectionsAreCorrectlyPopulated < BasicTest
    title 'AU PS Composition recommended sections are correctly populated'
    description 'Recommended sections SHOULD be correctly populated if a value is known'
    id :suite_100preview_au_ps_bundle_instance_au_ps_composition_recommended_sections_sections_should_populated
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../../metadata.yaml', __dir__))
    end
    
    run do
      
      validate_populated_sections_in_bundle(["11369-6", "30954-2", "47519-4", "46264-8"], ["title", "code", "text"], optional: true)
      
    end
    
  end
end
