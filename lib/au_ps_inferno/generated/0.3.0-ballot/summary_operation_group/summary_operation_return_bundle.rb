# frozen_string_literal: true

module AUPSTestKit
  class SummaryOperationReturnBundle < Inferno::Test
    title 'Server returns Bundle resource for Patient/[id]/$summary GET operation'
    description 'Server returns a valid Bundle resource as successful result of $summary operation.'
    id :au_ps_summary_operation_return_bundle

    input :patient_id,
          optional: true,
          description: 'To request Patient/{patient_id}/$summary'

    input :identifier,
          optional: true,
          description: 'To request Patient/$summary?identifier={identifier}'

    makes_request :summary_operation

    run do
        operation_path = if patient_id
                "Patient/#{patient_id}/$summary"
            else
                "Patient/$summary?identifier=#{identifier}"
            end
        fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_resource(profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle')
    end
  end
end
