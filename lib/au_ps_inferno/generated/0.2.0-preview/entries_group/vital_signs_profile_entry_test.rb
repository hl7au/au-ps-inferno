# frozen_string_literal: true

module AUPSTestKit
  class VitalSignsProfileEntryTest < Inferno::Test
    title 'Server returns Vital Signs Profile resource that matches the Vital Signs Profile profile'
    description %(
      This test will validate that the Vital Signs Profile resource returned from the server matches the Vital Signs Profile profile.
    )
    id :au_ps_vital_signs_profile_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/StructureDefinition/vitalsigns')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/StructureDefinition/vitalsigns')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/StructureDefinition/vitalsigns' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/StructureDefinition/vitalsigns')
        
      end
    end
  end
end
