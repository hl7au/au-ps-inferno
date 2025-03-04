# frozen_string_literal: true

module AUPSTestKit
  class DocumentreferenceEntryTest < Inferno::TestGroup
    title 'DocumentReference'
    description 'TODO description: DocumentreferenceEntryTest'
    id :au_ps_documentreference_entry_test

    test do
      title 'Server returns correct DocumentReference resource from the DocumentReference read interaction'
      description %(
        This test will verify that DocumentReference resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'DocumentReference' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'DocumentReference' with profile '' found."

        existing_resources.each do |r|
          fhir_read('DocumentReference', r.id)
          assert_response_status(200)
          assert_resource_type('DocumentReference')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns DocumentReference resource that matches the DocumentReference profile'
      description %(
        This test will validate that the DocumentReference resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'DocumentReference' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'DocumentReference' with profile '' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: '')
        end
      end
    end
  end
end
