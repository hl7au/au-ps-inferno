# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # The optional sections populated in the Composition resource.
  class AUPSRetrieveBundleCompositionOptionalSection100ballot < BasicTest
    title 'Composition contains optional sections with entry references'
    description 'Displays information about optional sections'
    id :au_ps_retrieve_bundle_composition_optional_sections_100ballot

    
    run do
      read_composition_sections_info(["42348-3", "104605-1", "47420-5", "11348-0", "10162-6", "81338-6", "18776-5", "29762-2", "8716-3"])
    end
    
  end
end
