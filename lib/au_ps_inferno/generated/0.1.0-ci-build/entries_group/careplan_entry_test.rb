# frozen_string_literal: true

module AUPSTestKit
  class CareplanEntryTest < Inferno::TestGroup
    title 'CarePlan'
    description 'TODO description: CareplanEntryTest'
    id :au_ps_careplan_entry_test

    test do
      title 'Server returns correct CarePlan resource from the CarePlan read interaction'
      description %(
        This test will verify that CarePlan resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'CarePlan' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'CarePlan' with profile '' found."

        existing_resources.each do |r|
          fhir_read('CarePlan', r.id)
          assert_response_status(200)
          assert_resource_type('CarePlan')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns CarePlan resource that matches the CarePlan profile'
      description %(
        This test will validate that the CarePlan resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'CarePlan' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'CarePlan' with profile '' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: '')
        end
      end
    end
  end
end
