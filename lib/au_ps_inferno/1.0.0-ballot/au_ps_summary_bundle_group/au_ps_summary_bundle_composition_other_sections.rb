# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # AU PS Composition Other Sections
  class AUPSSummaryBundleCompositionOtherSection100ballot < BasicTest
    title 'Composition contains other sections with entry references'
    description 'Displays information about other sections'
    id :au_ps_summary_bundle_composition_other_sections_100ballot

    
    run do
      check_other_sections(["11450-4", "48765-2", "10160-0", "11369-6", "30954-2", "47519-4", "46264-8", "42348-3", "104605-1", "47420-5", "11348-0", "10162-6", "81338-6", "18776-5", "29762-2", "8716-3"], {"11450-4"=>"Patient Summary Problems Section", "48765-2"=>"Patient Summary Allergies and Intolerances Section", "10160-0"=>"Patient Summary Medication Summary Section", "11369-6"=>"Patient Summary Immunizations Section", "30954-2"=>"Patient Summary Results Section", "47519-4"=>"Patient Summary History of Procedures Section", "46264-8"=>"Patient Summary Medical Devices Section", "42348-3"=>"Patient Summary Advance Directives Section", "104605-1"=>"Patient Summary Alerts Section", "47420-5"=>"Patient Summary Functional Status Section", "11348-0"=>"Patient Summary History of Past Illness Section", "10162-6"=>"Patient Summary History of Pregnancy Section", "81338-6"=>"Patient Summary Patient Story Section", "18776-5"=>"Patient Summary Plan of Care Section", "29762-2"=>"Patient Summary Social History Section", "8716-3"=>"Patient Summary Vital Signs Section"})
    end
    
  end
end
