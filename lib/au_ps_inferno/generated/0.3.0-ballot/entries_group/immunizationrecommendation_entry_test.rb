# frozen_string_literal: true

module AUPSTestKit
  class ImmunizationrecommendationEntryTest < Inferno::Test
    title 'Server returns ImmunizationRecommendation resource that matches the ImmunizationRecommendation profile'
    description %(
      This test will validate that the ImmunizationRecommendation resource returned from the server matches the ImmunizationRecommendation profile.
    )
    id :au_ps_immunizationrecommendation_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'ImmunizationRecommendation'
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'ImmunizationRecommendation' && r.meta&.profile&.include?('')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'ImmunizationRecommendation' with profile '' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r)
        
      end
    end
  end
end
