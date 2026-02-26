# frozen_string_literal: true

require_relative '../../utils/constants'

require_relative './au_ps_bundle_is_valid_test'

require_relative './au_ps_bundle_has_must_support_elements'

require_relative './au_ps_composition_must_support_elements'

require_relative './au_ps_composition_mandatory_sections'

require_relative './au_ps_composition_recommended_sections'

require_relative './au_ps_composition_optional_sections'

require_relative './au_ps_composition_other_sections'


module AUPSTestKit
  # Verify that the AU PS Bundle is valid
  class AUPSValidationGroup100preview < Inferno::TestGroup
    extend Constants

    title 'AU PS Bundle Validation'
    description 'Verify that an AU PS Bundle is valid and contains required must support elements.'
    id :au_ps_validation_group_100preview

    run_as_group

    
    test from: :au_ps_bundle_is_valid_test_100preview
    
    test from: :au_ps_bundle_has_must_support_elements_100preview
    
    test from: :au_ps_composition_must_support_elements_100preview
    
    test from: :au_ps_composition_mandatory_sections_100preview
    
    test from: :au_ps_composition_recommended_sections_100preview
    
    test from: :au_ps_composition_optional_sections_100preview
    
    test from: :au_ps_composition_other_sections_100preview
    
  end
end
