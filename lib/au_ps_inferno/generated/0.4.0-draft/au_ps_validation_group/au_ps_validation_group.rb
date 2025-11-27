# frozen_string_literal: true

require_relative './au_ps_bundle_is_valid_test'
require_relative './au_ps_bundle_has_must_support_elements'
require_relative './au_ps_composition_must_support_elements'
require_relative './au_ps_composition_mandatory_sections'
require_relative './au_ps_composition_recommended_sections'
require_relative './au_ps_composition_optional_sections'
require_relative './au_ps_composition_other_sections'
require_relative '../../../utils/constants'

module AUPSTestKit
  class AUPSValidationGroup < Inferno::TestGroup
    include Constants

    title TEXTS[:au_ps_validation_group][:title]
    description TEXTS[:au_ps_validation_group][:description]
    id :au_ps_validation_group
    run_as_group

    test from: :au_ps_bundle_is_valid_test
    test from: :au_ps_bundle_has_must_support_elements
    test from: :au_ps_composition_must_support_elements
    test from: :au_ps_composition_mandatory_sections
    test from: :au_ps_composition_recommended_sections
    test from: :au_ps_composition_optional_sections
    test from: :au_ps_composition_other_sections

  end
end
