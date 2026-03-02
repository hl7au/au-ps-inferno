# frozen_string_literal: true


require_relative 'lib/au_ps_inferno/1.0.0-ballot/bundle_validation_high_order_group/bundle_has_must_support_elements_generic_bundle_group/bundle_has_must_support_elements_generic_bundle_group.rb'

require_relative 'lib/au_ps_inferno/1.0.0-ballot/bundle_validation_high_order_group/composition_must_support_elements_generic_bundle_group/composition_must_support_elements_generic_bundle_group.rb'

require_relative 'lib/au_ps_inferno/1.0.0-ballot/bundle_validation_high_order_group/composition_mandatory_sections_generic_bundle_group/composition_mandatory_sections_generic_bundle_group.rb'

require_relative 'lib/au_ps_inferno/1.0.0-ballot/bundle_validation_high_order_group/composition_recommended_sections_generic_bundle_group/composition_recommended_sections_generic_bundle_group.rb'

require_relative 'lib/au_ps_inferno/1.0.0-ballot/bundle_validation_high_order_group/composition_optional_sections_generic_bundle_group/composition_optional_sections_generic_bundle_group.rb'

require_relative 'lib/au_ps_inferno/1.0.0-ballot/bundle_validation_high_order_group/composition_other_sections_generic_bundle_group/composition_other_sections_generic_bundle_group.rb'


module AUPSTestKit
  # Automatically generated high order group for Bundle validation
  class BundleValidationHighOrderGroup < Inferno::TestGroup
    title 'Bundle validation'
    description 'Displays information about Bundle validation in the Composition resource.'
    id :bundle_validation

    
    group from: :bundle_has_must_support_elements_generic_bundle_group
    
    group from: :composition_must_support_elements_generic_bundle_group
    
    group from: :composition_mandatory_sections_generic_bundle_group
    
    group from: :composition_recommended_sections_generic_bundle_group
    
    group from: :composition_optional_sections_generic_bundle_group
    
    group from: :composition_other_sections_generic_bundle_group
    
  end
end
