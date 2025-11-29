# frozen_string_literal: true

require 'net/http'
require 'uri'

require_relative '../utils/basic_test_class'

module AUPSTestKit
  class AUPSSummaryValidBundle < BasicTest
    id :au_ps_summary_valid_bundle
    title TEXTS[:au_ps_summary_valid_bundle][:title]
    description TEXTS[:au_ps_summary_valid_bundle][:description]

    input :patient_id,
          optional: true,
          description: 'To request Patient/{patient_id}/$summary'

    input :identifier,
          optional: true,
          description: 'To request Patient/$summary?identifier={identifier}'

    makes_request :summary_operation

    def skip_test?
      (patient_id.blank? && identifier.blank?) || url.blank?
    end

    def operation_path
      if patient_id
        "Patient/#{patient_id}/$summary"
      else
        "Patient/$summary?identifier=#{identifier}"
      end
    end

    def get_and_save_data
      info 'Making $summary operation request'
      response = fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
      resource_from_request = FHIR.from_contents(response.response_body)
      scratch[:bundle_ips_resource] = resource_from_request
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    run do
      skip_if url.blank?, 'No FHIR server specified'
      get_and_save_data
      validate_ips_bundle
    end
  end
end
