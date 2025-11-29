# frozen_string_literal: true

require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The server declares support for the $docref operation in its CapabilityStatement
  class DocrefOperationSupport < BasicTest
    title 'Server declares support for $docref operation in CapabilityStatement'
    description 'The IPS Server declares support for DocumentReference/$docref operation in' \
      'its server CapabilityStatement'
    id :au_ps_docref_operation_support
    optional

    run do
      fhir_get_capability_statement
      assert_response_status(200)
      assert_resource_type(:capability_statement)

      operations = resource.rest&.flat_map do |rest|
        rest.resource
            &.select { |r| r.type == 'DocumentReference' && r.respond_to?(:operation) }
            &.flat_map(&:operation)
      end&.compact

      op_profile = 'http://hl7.org/fhir/uv/ipa/OperationDefinition/docref'

      operation_defined = operations.any? do |operation|
        operation.definition == op_profile || operation.name.downcase == 'docref'
      end

      assert operation_defined,
             'Server CapabilityStatement did not declare support for $docref operation in DocumentReference resource.'
    end
  end
end
