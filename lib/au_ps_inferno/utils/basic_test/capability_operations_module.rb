# frozen_string_literal: true

module AUPSTestKit
  # CapabilityStatement operation discovery (summary, docref, etc.).
  module BasicTestCapabilityOperationsModule
    def operation_defined?(operations, op_def_url, names_arr, scratch_key)
      operation_defined = operations.any? do |operation|
        operation.definition == op_def_url || names_arr.include?(operation.name.downcase)
      end

      if operation_defined
        info "Server CapabilityStatement declares support for operation #{op_def_url}: ✅ Declared"
      else
        info "Server CapabilityStatement does not declare support for operation #{op_def_url}. " \
             'This operation is not required by AU PS; this message is informational only.'
      end

      scratch[scratch_key] = operation_defined
    end

    def operations
      fhir_get_capability_statement
      scratch[:capability_statement] = resource
      resource.rest&.flat_map do |rest|
        select_op(rest)
      end&.compact
    end

    def select_op(rest)
      rest.resource
          &.select { |res| res.respond_to?(:operation) }
          &.flat_map(&:operation)
    end

    def summary_op_defined?
      operation_defined?(operations, 'http://hl7.org/fhir/uv/ips/OperationDefinition/summary',
                         %w[summary patient-summary], :summary_op_defined)
    end
  end
end
