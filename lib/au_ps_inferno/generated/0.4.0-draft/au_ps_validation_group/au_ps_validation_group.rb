# frozen_string_literal: true

require_relative './au_ps_bundle_is_valid_test'
require_relative './au_ps_bundle_has_must_support_elements'
require_relative './au_ps_composition_must_support_elements'

module AUPSTestKit
  class AUPSValidationGroup < Inferno::TestGroup
    title 'AU PS Bundle Validation'
    description 'Verify that an AU PS Bundle is valid and contains required must support elements.'
    id :au_ps_validation_group
    run_as_group

    test from: :au_ps_bundle_is_valid_test
    test from: :au_ps_bundle_has_must_support_elements
    test from: :au_ps_composition_must_support_elements

  end
end
