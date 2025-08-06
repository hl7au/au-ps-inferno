# frozen_string_literal: true

module AUPSTestKit
  class DocumentreferenceEntryTest < Inferno::Test
    title 'Server returns DocumentReference resource that matches the DocumentReference profile'
    description %(
      This test will validate that the DocumentReference resource returned from the server matches the DocumentReference profile.
    )
    id :au_ps_documentreference_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'DocumentReference'
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'DocumentReference' && r.meta&.profile&.include?('')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'DocumentReference' with profile '' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r)
        
      end
    end
  end
end
