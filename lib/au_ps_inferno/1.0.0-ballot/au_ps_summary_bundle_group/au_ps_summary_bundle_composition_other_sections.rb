# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # AU PS Composition Other Sections
  class AUPSSummaryBundleCompositionOtherSection100ballot < BasicTest
    title 'Composition contains other sections with entry references'
    description 'Displays information about other sections'
    id :au_ps_summary_bundle_composition_other_sections_100ballot

    
    run do
      check_other_sections
    end
    
  end
end
