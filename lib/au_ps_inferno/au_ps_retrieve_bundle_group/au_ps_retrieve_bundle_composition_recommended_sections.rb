# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The recommended sections populated in the Composition resource.
  class AUPSRetrieveBundleCompositionRecommendedSection < BasicTest
    title t_title(:au_ps_retrieve_bundle_composition_recommended_sections)
    description t_description(:au_ps_retrieve_bundle_composition_recommended_sections)
    id :au_ps_retrieve_bundle_composition_recommended_sections

    run do
      read_composition_recommended_sections_info
    end
  end
end
