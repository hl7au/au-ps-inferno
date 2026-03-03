# frozen_string_literal: true


require_relative 'bundle_validation'

require_relative 'bundle_has_must_support_elements'

require_relative 'composition_must_support_elements'

require_relative 'composition_mandatory_sections'

require_relative 'composition_recommended_sections'

require_relative 'composition_optional_sections'

require_relative 'composition_undefined_sections'


module AUPSTestKit
  # Automatically generated high order group for Retrieve Bundle validation
  class AUPSSuite100ballotRetrieveBundleValidation < Inferno::TestGroup
    title 'Retrieve Bundle validation'
    description 'Displays information about Retrieve Bundle validation in the Composition resource.'
    id :suite_100ballot_retrieve_bundle_validation

    
    group from: :suite_100ballot_retrieve_bundle_validation_bundle_validation
    
    group from: :suite_100ballot_retrieve_bundle_validation_bundle_has_must_support_elements
    
    group from: :suite_100ballot_retrieve_bundle_validation_composition_must_support_elements
    
    group from: :suite_100ballot_retrieve_bundle_validation_composition_mandatory_sections
    
    group from: :suite_100ballot_retrieve_bundle_validation_composition_recommended_sections
    
    group from: :suite_100ballot_retrieve_bundle_validation_composition_optional_sections
    
    group from: :suite_100ballot_retrieve_bundle_validation_composition_undefined_sections
    
  end
end
