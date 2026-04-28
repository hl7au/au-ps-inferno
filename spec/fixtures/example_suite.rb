# frozen_string_literal: true

module ExampleTestKit
  class ExampleServerSuite < Inferno::TestSuite
    id 'example_server_suite'

    input :url
    input :bearer_token
    input :encounter_id

    fhir_client do
      url :url
      bearer_token :bearer_token
    end

    fhir_resource_validator do
    end

    group do
      id :encounter_group

      test do
        id :read
        title 'Read Encounter'

        makes_request :encounter_read

        run do
          fhir_read(:encounter, encounter_id, name: :encounter_read)

          assert_response_status(200)
          assert_resource_type(FHIR::Encounter)
        end
      end

      test do
        id :validate
        title 'Validate Encounter Resource'

        uses_request :encounter_read

        run do
          assert_valid_resource
        end
      end
    end
  end
end
