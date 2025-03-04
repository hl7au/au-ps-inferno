# frozen_string_literal: true

module AUPSTestKit
  class ConsentEntryTest < Inferno::TestGroup
    title 'Consent'
    description 'TODO description: ConsentEntryTest'
    id :au_ps_consent_entry_test

    test do
      title 'Server returns correct Consent resource from the Consent read interaction'
      description %(
        This test will verify that Consent resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Consent' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'Consent' with profile '' found."

        existing_resources.each do |r|
          fhir_read('Consent', r.id)
          assert_response_status(200)
          assert_resource_type('Consent')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Consent resource that matches the Consent profile'
      description %(
        This test will validate that the Consent resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Consent' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'Consent' with profile '' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: '')
        end
      end
    end
  end
end
