# frozen_string_literal: true

require_relative '../utils/basic_test_class'

module AUPSTestKit
  # IPS recommended operations referenced as supported in CapabilityStatement
  class AUPSCSSupportsIPSRecommendedOPS < BasicTest
    title t_title(:au_ps_cs_supports_ips_recommended_ops)
    description t_description(:au_ps_cs_supports_ips_recommended_ops)
    id :au_ps_cs_supports_ips_recommended_ops

    def operation_defined?(operations, op_def_url, names_arr, scratch_key)
      operation_defined = operations.any? do |operation|
        operation.definition == op_def_url || names_arr.include?(operation.name.downcase)
      end

      message_base = 'Server CapabilityStatement declares support for operation with operation definition'

      info "#{message_base} #{op_def_url}: #{operation_defined}"

      scratch[scratch_key] = operation_defined
    end

    run do
      skip_if scratch[:capability_statement].blank?, 'No CapabilityStatement resource provided'
      resource = scratch[:capability_statement]
      operations = resource.rest&.flat_map do |rest|
        rest.resource
            &.select { |res| res.respond_to?(:operation) }
            &.flat_map(&:operation)
      end&.compact

      operation_defined?(operations, 'http://hl7.org/fhir/uv/ips/OperationDefinition/summary',
                         %w[summary patient-summary], :summary_op_defined)
      operation_defined?(operations, 'http://hl7.org/fhir/uv/ipa/OperationDefinition/docref', %w[docref],
                         :docref_op_defined)
    end
  end
end
