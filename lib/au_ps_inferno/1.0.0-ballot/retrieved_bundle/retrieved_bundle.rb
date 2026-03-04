# frozen_string_literal: true


require_relative 'bundle_validation'

require_relative 'bundle_must_support_elements'

require_relative 'composition_must_support_elements'

require_relative 'composition_mandatory_sections'

require_relative 'composition_recommended_sections'

require_relative 'composition_optional_sections'

require_relative 'composition_undefined_sections'


module AUPSTestKit
  # Automatically generated high order group for Retrieved Bundle
  class AUPSSuite100ballotRetrievedBundle < Inferno::TestGroup
    title 'Retrieved Bundle'
    description 'Validates an AU PS bundle retrieved from the server for profile conformance, Must Support elements, and composition sections.'
    id :suite_100ballot_retrieved_bundle
    
    
    run_as_group
    

    
    group from: :suite_100ballot_retrieved_bundle_bundle_validation
    
    group from: :suite_100ballot_retrieved_bundle_bundle_must_support_elements
    
    group from: :suite_100ballot_retrieved_bundle_composition_must_support_elements
    
    group from: :suite_100ballot_retrieved_bundle_composition_mandatory_sections
    
    group from: :suite_100ballot_retrieved_bundle_composition_recommended_sections
    
    group from: :suite_100ballot_retrieved_bundle_composition_optional_sections
    
    group from: :suite_100ballot_retrieved_bundle_composition_undefined_sections
    
  end
end
