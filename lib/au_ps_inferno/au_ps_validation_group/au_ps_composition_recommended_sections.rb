# frozen_string_literal: true

require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The recommended sections populated in the Composition resource.
  class AUPSCompositionRecommendedSection < BasicTest
    title 'Composition contains recommended sections with entry references'
    description 'Displays information about recommended sections'
    id :au_ps_composition_recommended_sections

    run do
      read_composition_recommended_sections_info
    end
  end
end
