# frozen_string_literal: true


require_relative 'bundle_has_must_support_elements_generic_bundle_group/bundle_has_must_support_elements_generic_bundle_group'

require_relative 'composition_must_support_elements_generic_bundle_group/composition_must_support_elements_generic_bundle_group'

require_relative 'composition_mandatory_sections_generic_bundle_group/composition_mandatory_sections_generic_bundle_group'

require_relative 'composition_recommended_sections_generic_bundle_group/composition_recommended_sections_generic_bundle_group'

require_relative 'composition_optional_sections_generic_bundle_group/composition_optional_sections_generic_bundle_group'

require_relative 'composition_other_sections_generic_bundle_group/composition_other_sections_generic_bundle_group'


module AUPSTestKit
  # Automatically generated high order group for Retrieve Bundle validation
  class RetrieveBundleValidationHighOrderGroup < Inferno::TestGroup
    title 'Retrieve Bundle validation'
    description 'Displays information about Retrieve Bundle validation in the Composition resource.'
    id :retrieve_bundle_validation

    
    group from: :retrieve_bundle_validation_bundle_has_must_support_elements_generic_bundle_group
    
    group from: :retrieve_bundle_validation_composition_must_support_elements_generic_bundle_group
    
    group from: :retrieve_bundle_validation_composition_mandatory_sections_generic_bundle_group
    
    group from: :retrieve_bundle_validation_composition_recommended_sections_generic_bundle_group
    
    group from: :retrieve_bundle_validation_composition_optional_sections_generic_bundle_group
    
    group from: :retrieve_bundle_validation_composition_other_sections_generic_bundle_group
    
  end
end
