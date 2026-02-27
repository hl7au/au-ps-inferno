# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # AU PS Composition Other Sections
  class AUPSRetrieveBundleCompositionOtherSection100ballot < BasicTest
    title 'Composition contains other sections with entry references'
    description 'Displays information about other sections'
    id :au_ps_retrieve_bundle_composition_other_sections_100ballot

    
    run do
      check_other_sections(["11450-4", "48765-2", "10160-0", "11369-6", "30954-2", "47519-4", "46264-8", "42348-3", "104605-1", "47420-5", "11348-0", "10162-6", "81338-6", "18776-5", "29762-2", "8716-3"], [{:expression=>"author", :label=>"author"}, {:expression=>"date", :label=>"date"}, {:expression=>"section", :label=>"section"}, {:expression=>"status", :label=>"status"}, {:expression=>"subject", :label=>"subject"}, {:expression=>"title", :label=>"title"}, {:expression=>"type", :label=>"type"}])
    end
    
  end
end
