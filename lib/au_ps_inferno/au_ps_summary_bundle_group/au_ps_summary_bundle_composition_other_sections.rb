# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # AU PS Composition Other Sections
  class AUPSSummaryBundleCompositionOtherSection < BasicTest
    title t_title(:au_ps_summary_bundle_composition_other_sections)
    description t_description(:au_ps_summary_bundle_composition_other_sections)
    id :au_ps_summary_bundle_composition_other_sections

    run do
      check_other_sections
    end
  end
end
