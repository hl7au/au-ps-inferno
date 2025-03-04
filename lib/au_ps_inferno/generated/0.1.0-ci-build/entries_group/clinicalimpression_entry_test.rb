# frozen_string_literal: true

module AUPSTestKit
  class ClinicalimpressionEntryTest < Inferno::TestGroup
    title 'ClinicalImpression'
    description 'TODO description: ClinicalimpressionEntryTest'
    id :au_ps_clinicalimpression_entry_test

    test do
      title 'Server returns correct ClinicalImpression resource from the ClinicalImpression read interaction'
      description %(
        This test will verify that ClinicalImpression resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'ClinicalImpression' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'ClinicalImpression' with profile '' found."

        existing_resources.each do |r|
          fhir_read('ClinicalImpression', r.id)
          assert_response_status(200)
          assert_resource_type('ClinicalImpression')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns ClinicalImpression resource that matches the ClinicalImpression profile'
      description %(
        This test will validate that the ClinicalImpression resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'ClinicalImpression' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'ClinicalImpression' with profile '' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: '')
        end
      end
    end
  end
end
