# frozen_string_literal: true

require_relative '../../utils/basic_test_with_url'

module AUPSTestKit
  # Verifies that the CapabilityStatement declares support for IPS recommended operations.
  class AUPSCSSupportsIPSRecommendedOPS100preview < BasicTestWithURL
    title 'CapabilityStatement supports IPS Recommended Operations'
    description 'Verifies that the CapabilityStatement declares support for IPS recommended operations (e.g. $summary, $docref).'
    id :au_ps_cs_supports_ips_recommended_ops_100preview

    run do
      omit_unless_fhir_server_bundle?
      summary_op_defined?
      operation_defined?(operations, 'http://hl7.org/fhir/uv/ipa/OperationDefinition/docref', %w[docref],
                         :docref_op_defined)
    end
  end
end
