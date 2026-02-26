# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # The recommended sections populated in the Composition resource.
  class AUPSRetrieveBundleCompositionRecommendedSection100ballot < BasicTest
    title 'Composition contains recommended sections with entry references'
    description 'Displays information about recommended sections'
    id :au_ps_retrieve_bundle_composition_recommended_sections_100ballot

    
    run do
      read_composition_sections_info(["11369-6", "30954-2", "47519-4", "46264-8"])
    end
    
  end
end
