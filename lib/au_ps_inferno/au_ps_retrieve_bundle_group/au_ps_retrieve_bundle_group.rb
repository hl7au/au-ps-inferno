# frozen_string_literal: true

require_relative '../utils/constants'
require_relative './au_ps_retrieve_valid_bundle'
require_relative './au_ps_retrieve_bundle_has_must_support_elements'
require_relative './au_ps_retrieve_bundle_composition_must_support_elements'
require_relative './au_ps_retrieve_bundle_composition_mandatory_sections'
require_relative './au_ps_retrieve_bundle_composition_recommended_sections'
require_relative './au_ps_retrieve_bundle_composition_optional_sections'
require_relative './au_ps_retrieve_bundle_composition_other_sections'

module AUPSTestKit
  # Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify
  # is valid AU PS Bundle
  class AUPSRetrieveBundleGroup < Inferno::TestGroup
    extend Constants

    title 'Retrieve AU PS Bundle validation tests'
    description 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and ' \
      'verify response is valid AU PS Bundle'
    id :au_ps_retrieve_bundle_group

    run_as_group

    test from: :au_ps_retrieve_valid_bundle
    test from: :au_ps_retrieve_bundle_has_must_support_elements
    test from: :au_ps_retrieve_bundle_composition_must_support_elements
    test from: :au_ps_retrieve_bundle_composition_mandatory_sections
    test from: :au_ps_retrieve_bundle_composition_recommended_sections
    test from: :au_ps_retrieve_bundle_composition_optional_sections
    test from: :au_ps_retrieve_bundle_composition_other_sections
  end
end
