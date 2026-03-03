# frozen_string_literal: true


require_relative 'bundle_has_must_support_elements/bundle_has_must_support_elements'

require_relative 'composition_must_support_elements/composition_must_support_elements'

require_relative 'composition_mandatory_sections/composition_mandatory_sections'

require_relative 'composition_recommended_sections/composition_recommended_sections'

require_relative 'composition_optional_sections/composition_optional_sections'

require_relative 'composition_undefined_sections/composition_undefined_sections'


module AUPSTestKit
  # Automatically generated high order group for Bundle validation
  class AUPSSuite100ballotBundleValidation < Inferno::TestGroup
    title 'Bundle validation'
    description 'Displays information about Bundle validation in the Composition resource.'
    id :suite_100ballot_bundle_validation

    
    group from: :suite_100ballot_bundle_validation_bundle_has_must_support_elements
    
    group from: :suite_100ballot_bundle_validation_composition_must_support_elements
    
    group from: :suite_100ballot_bundle_validation_composition_mandatory_sections
    
    group from: :suite_100ballot_bundle_validation_composition_recommended_sections
    
    group from: :suite_100ballot_bundle_validation_composition_optional_sections
    
    group from: :suite_100ballot_bundle_validation_composition_undefined_sections
    
  end
end
