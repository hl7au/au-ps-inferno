# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The recommended sections populated in the Composition resource.
  class AUPSRetrieveBundleCompositionRecommendedSection < BasicTest
    title 'Composition contains recommended sections with entry references'
    description 'Displays information about recommended sections'
    id :au_ps_retrieve_bundle_composition_recommended_sections

    run do
      read_composition_recommended_sections_info
    end
  end
end
