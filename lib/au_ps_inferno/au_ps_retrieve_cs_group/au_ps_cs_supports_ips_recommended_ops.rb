# frozen_string_literal: true

require_relative '../utils/basic_test_class'

module AUPSTestKit
  # IPS recommended operations referenced as supported in CapabilityStatement
  class AUPSCSSupportsIPSRecommendedOPS < BasicTest
    title 'CapabilityStatement supports IPS Recommended Operations'
    description 'IPS recommended operations referenced as supported in CapabilityStatement'
    id :au_ps_cs_supports_ips_recommended_ops

    run do
      summary_op_defined?
      operation_defined?(operations, 'http://hl7.org/fhir/uv/ipa/OperationDefinition/docref', %w[docref],
                         :docref_op_defined)
    end
  end
end
