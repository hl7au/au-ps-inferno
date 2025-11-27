# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  class AUPSCompositionRecommendedSection < BasicTest
    title 'Composition contains recommended sections with entry references'
    description 'Displays information about recommended sections'
    id :au_ps_composition_recommended_sections

    run do
      get_composition_sections_info(RECOMMENDED_SECTIONS)
    end
  end
end
