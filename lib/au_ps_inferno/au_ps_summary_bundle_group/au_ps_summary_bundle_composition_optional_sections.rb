# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  class AUPSSummaryBundleCompositionOptionalSection < BasicTest
    title TEXTS[:au_ps_summary_bundle_composition_optional_sections][:title]
    description TEXTS[:au_ps_summary_bundle_composition_optional_sections][:description]
    id :au_ps_summary_bundle_composition_optional_sections

    run do
      get_composition_sections_info(OPTIONAL_SECTIONS)
    end
  end
end
