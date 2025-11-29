# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The optional sections populated in the Composition resource.
  class AUPSRetrieveBundleCompositionOptionalSection < BasicTest
    title t_title(:au_ps_retrieve_bundle_composition_optional_sections)
    description t_description(:au_ps_retrieve_bundle_composition_optional_sections)
    id :au_ps_retrieve_bundle_composition_optional_sections

    run do
      get_composition_optional_sections_info
    end
  end
end
