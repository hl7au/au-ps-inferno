# frozen_string_literal: true

module AUPSTestKit
  class SummaryOperationReturnBundle < Inferno::Test
    title 'Server returns valid Bundle resource for $summary operation or validates provided Bundle'
    description 'Validates that a Bundle resource conforms to the AU PS Bundle profile. The test can either make a $summary operation request to retrieve and validate a Bundle, or validate a Bundle resource provided as input.'
    id :au_ps_summary_operation_return_bundle

    input :patient_id,
          optional: true,
          description: 'To request Patient/{patient_id}/$summary'

    input :identifier,
          optional: true,
          description: 'To request Patient/$summary?identifier={identifier}'

    input :bundle_resource,
          optional: true,
          description: 'If you want to check existing Bundle resource',
          type: 'textarea'

    makes_request :summary_operation

    run do
      profile_with_version = 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.4.0-draft'
      if bundle_resource.present?
        resource = FHIR.from_contents(bundle_resource)
        resource_is_valid?(resource: resource, profile_url: profile_with_version)

        errors_found = messages.any? { |message| message[:type] == "error" }

        assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
      else
        operation_path = if patient_id
                           "Patient/#{patient_id}/$summary"
                         else
                           "Patient/$summary?identifier=#{identifier}"
                         end
        fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_resource(profile_url: profile_with_version)
      end
    end
  end
end
