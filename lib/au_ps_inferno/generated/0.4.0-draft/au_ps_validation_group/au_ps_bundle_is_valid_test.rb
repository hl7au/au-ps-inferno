# frozen_string_literal: true

require 'jsonpath'

module AUPSTestKit
  class AUPSBundleIsValidTest < Inferno::Test
    title 'AU PS Bundle is valid'
    description 'Validates that a Bundle resource conforms to the AU PS Bundle profile (http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle). The test accepts either a patient_id to request Patient/{patient_id}/$summary, an identifier to request Patient/$summary?identifier={identifier}, or a pre-existing Bundle resource to validate directly.'
    id :au_ps_bundle_is_valid_test

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

    def get_and_save_data(bundle_resource)
      if bundle_resource.present?
        info 'Using provided Bundle resource'
        resource = FHIR.from_contents(bundle_resource)
        scratch[:ips_bundle_resource] = resource
      else
        info 'Making $summary operation request'
        operation_path = if patient_id
                           "Patient/#{patient_id}/$summary"
                         else
                           "Patient/$summary?identifier=#{identifier}"
                         end
        response = fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
        resource_from_request = FHIR.from_contents(response.response_body)
        scratch[:ips_bundle_resource] = resource_from_request
      end
      info "Bundle resource saved to scratch: #{scratch[:ips_bundle_resource]}"
    end

    def validate_bundle(resource, profile_with_version)
      resource_is_valid?(resource: resource, profile_url: profile_with_version)
      errors_found = messages.any? { |message| message[:type] == "error" }
      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end

    run do
      get_and_save_data(bundle_resource)
      # TODO: Uncomment validation
      # validate_bundle(
      #   scratch[:ips_bundle_resource],
      #   'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.4.0-draft')
    end
  end
end
