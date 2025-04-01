# frozen_string_literal: true

module AUPSTestKit
  class ClinicalimpressionEntryTest < Inferno::Test
    title 'Server returns ClinicalImpression resource that matches the ClinicalImpression profile'
    description %(
      This test will validate that the ClinicalImpression resource returned from the server matches the ClinicalImpression profile.
    )
    id :au_ps_clinicalimpression_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'ClinicalImpression'
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'ClinicalImpression' && r.meta&.profile&.include?('')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'ClinicalImpression' with profile '' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r)
        
      end
    end
  end
end
