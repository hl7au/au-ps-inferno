# frozen_string_literal: true

module AUPSTestKit
  class CapabilityStatementExistsAndValid < Inferno::Test
    title 'Server provides CapabilityStatement with IPS $summary and $docref operations'
    description "This test retrieves the server's CapabilityStatement and verifies that it declares support for both the IPS $summary operation (for generating patient summaries) and the $docref operation (for retrieving clinical documents). The test checks for operation definitions matching the canonical URLs from the IPS and IPA specifications, or operation names matching 'summary', 'patient-summary', or 'docref'."
    id :au_ps_capability_statement_exists_and_valid
    optional

    input :url,
          title: 'FHIR Server Base Url',
          optional: true

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

    input :header_name,
          title: 'Header name',
          optional: true
    input :header_value,
          title: 'Header value',
          optional: true

    def is_operation_defined?(operations, op_def_url, names_arr, scratch_key)
      operation_defined = operations.any? do |operation|
        operation.definition == op_def_url || names_arr.include?(operation.name.downcase)
      end

      info "Server CapabilityStatement declares support for operation with operation definition #{op_def_url}: #{operation_defined}"

      scratch[scratch_key] = operation_defined
    end

    run do
      fhir_get_capability_statement
      assert_response_status(200)
      assert_resource_type(:capability_statement)

      operations = resource.rest&.flat_map do |rest|
        rest.resource
          &.select { |r| r.respond_to?(:operation) }
          &.flat_map(&:operation)
      end&.compact

      is_operation_defined?(operations, 'http://hl7.org/fhir/uv/ips/OperationDefinition/summary', %w[summary patient-summary], :summary_op_defined)
      is_operation_defined?(operations, 'http://hl7.org/fhir/uv/ipa/OperationDefinition/docref', %w[docref], :docref_op_defined)

    end
  end
end
