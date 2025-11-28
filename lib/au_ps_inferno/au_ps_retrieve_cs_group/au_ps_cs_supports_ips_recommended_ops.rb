# frozen_string_literal: true

require_relative '../utils/constants'

module AUPSTestKit
  class AUPSCSSupportsIPSRecommendedOPS < Inferno::Test
    include Constants

    title TEXTS[:au_ps_cs_supports_ips_recommended_ops][:title]
    description TEXTS[:au_ps_cs_supports_ips_recommended_ops][:description]
    id :au_ps_cs_supports_ips_recommended_ops

    def is_operation_defined?(operations, op_def_url, names_arr, scratch_key)
      operation_defined = operations.any? do |operation|
        operation.definition == op_def_url || names_arr.include?(operation.name.downcase)
      end

      info "Server CapabilityStatement declares support for operation with operation definition #{op_def_url}: #{operation_defined}"

      scratch[scratch_key] = operation_defined
    end

    run do
      resource = scratch[:capability_statement]
      operations = resource.rest&.flat_map do |rest|
        rest.resource
            &.select { |r| r.respond_to?(:operation) }
            &.flat_map(&:operation)
      end&.compact

      is_operation_defined?(operations, 'http://hl7.org/fhir/uv/ips/OperationDefinition/summary',
                            %w[summary patient-summary], :summary_op_defined)
      is_operation_defined?(operations, 'http://hl7.org/fhir/uv/ipa/OperationDefinition/docref', %w[docref],
                            :docref_op_defined)
    end
  end
end
