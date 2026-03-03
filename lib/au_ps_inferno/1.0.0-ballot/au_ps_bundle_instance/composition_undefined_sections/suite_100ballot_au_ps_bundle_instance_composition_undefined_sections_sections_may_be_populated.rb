# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Sections MAY be populated
  class AUPSSuite100ballotAuPsBundleInstanceCompositionUndefinedSectionsSectionsMayBePopulated < BasicTest
    title 'Sections MAY be populated'
    description ''
    id :suite_100ballot_au_ps_bundle_instance_composition_undefined_sections_sections_may_be_populated
    
    optional
    
    
    run do
      
      validate_populated_undefined_sections_in_bundle(["11450-4", "48765-2", "10160-0", "11369-6", "30954-2", "47519-4", "46264-8", "42348-3", "104605-1", "47420-5", "11348-0", "10162-6", "81338-6", "18776-5", "29762-2", "8716-3"], ["title", "code", "text"])
      
    end
    
  end
end
