# frozen_string_literal: true

module AUPSTestKit
  class ImagingstudyIpsEntryTest < Inferno::TestGroup
    title 'ImagingStudy (IPS)'
    description 'TODO description: ImagingstudyIpsEntryTest'
    id :au_ps_imagingstudy_ips_entry_test

    test do
      title 'Server returns correct ImagingStudy resource from the ImagingStudy read interaction'
      description %(
        This test will verify that ImagingStudy resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'ImagingStudy' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'ImagingStudy' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips' found."

        existing_resources.each do |r|
          fhir_read('ImagingStudy', r.id)
          assert_response_status(200)
          assert_resource_type('ImagingStudy')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns ImagingStudy resource that matches the ImagingStudy profile'
      description %(
        This test will validate that the ImagingStudy resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'ImagingStudy' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'ImagingStudy' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips')
        end
      end
    end
  end
end
