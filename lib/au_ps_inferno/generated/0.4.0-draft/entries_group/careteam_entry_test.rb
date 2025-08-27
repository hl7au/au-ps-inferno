# frozen_string_literal: true

module AUPSTestKit
  class CareteamEntryTest < Inferno::Test
    title 'Server returns CareTeam resource that matches the CareTeam profile'
    description %(
      This test will validate that the CareTeam resource returned from the server matches the CareTeam profile.
    )
    id :au_ps_careteam_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'CareTeam'
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'CareTeam' && r.meta&.profile&.include?('')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'CareTeam' with profile '' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r)
        
      end
    end
  end
end
