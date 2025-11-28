# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  class AUPSRetrieveBundleCompositionMandatorySection < BasicTest
    title TEXTS[:au_ps_composition_mandatory_sections][:title]
    description TEXTS[:au_ps_composition_mandatory_sections][:description]
    id :au_ps_retrieve_bundle_composition_mandatory_sections

    run do
      get_composition_sections_info(MANDATORY_SECTIONS)
    end
  end
end
