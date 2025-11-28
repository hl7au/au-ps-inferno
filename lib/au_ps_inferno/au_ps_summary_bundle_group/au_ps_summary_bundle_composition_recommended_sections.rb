# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'


module AUPSTestKit
  class AUPSSummaryBundleCompositionRecommendedSection < BasicTest
    title TEXTS[:au_ps_summary_bundle_composition_recommended_sections][:title]
    description TEXTS[:au_ps_summary_bundle_composition_recommended_sections][:description]
    id :au_ps_summary_bundle_composition_recommended_sections

    run do
      get_composition_sections_info(RECOMMENDED_SECTIONS)
    end
  end
end
