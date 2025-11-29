# frozen_string_literal: true

require_relative '../utils/basic_test_class'

module AUPSTestKit
  class DocrefOperationSuccess < BasicTest
    title 'Server responds successfully to a $docref operation'
    description 'This test creates a $docref operation request for a patient.  Note that this currently does not request an IPS bundle specifically therefore does not validate the content.'
    id :au_ps_docref_operation_success
    optional

    input :patient_id

    run do
      parameters = FHIR::Parameters.new(
        parameter: [
          {
            name: 'patient',
            valueId: patient_id
          }
        ]
      )
      fhir_operation('/DocumentReference/$docref', body: parameters)
      assert_response_status(200)
    end
  end
end
