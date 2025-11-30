# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The optional sections populated in the Composition resource.
  class AUPSRetrieveBundleCompositionOptionalSection < BasicTest
    title 'Composition contains optional sections with entry references'
    description 'Displays information about optional sections'
    id :au_ps_retrieve_bundle_composition_optional_sections

    run do
      read_composition_optional_sections_info
    end
  end
end
