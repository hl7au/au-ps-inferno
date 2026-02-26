# frozen_string_literal: true

class Generator
  # Holds the static test definitions for au_ps_retrieve_cs_group.
  #
  # Three tests: CS is valid (BasicTestWithURL), CS supports IPS recommended ops (BasicTest),
  # CS supports AU PS profiles (BasicTest with custom methods). All use FHIR client.
  module RetrieveCSGroupTests
    # Array of test spec hashes. For custom_template tests, other keys (e.g. extra_require) may be used.
    TESTS = [
      {
        file_base: 'au_ps_cs_is_valid_test',
        class_base: 'AUPSCSIsValid',
        id_base: 'au_ps_cs_is_valid',
        title: 'CapabilityStatement is valid',
        description: 'Verify CapabilityStatement resource is valid',
        base_class_require: '../../utils/basic_test_with_url',
        base_class_name: 'BasicTestWithURL',
        description_comment: 'Verify CapabilityStatement resource is valid',
        run_code: "skip_if url.blank?, 'No FHIR server specified'\n      fhir_get_capability_statement\n      " \
                  "scratch[:capability_statement] = resource\n      info \"Capability Statement saved to scratch: " \
                  "\#{scratch[:capability_statement]}\"\n      assert_response_status(200)\n      " \
                  'assert_resource_type(:capability_statement)'
      },
      {
        file_base: 'au_ps_cs_supports_ips_recommended_ops',
        class_base: 'AUPSCSSupportsIPSRecommendedOPS',
        id_base: 'au_ps_cs_supports_ips_recommended_ops',
        title: 'CapabilityStatement supports IPS Recommended Operations',
        description: 'IPS recommended operations referenced as supported in CapabilityStatement',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'IPS recommended operations referenced as supported in CapabilityStatement',
        run_code: "skip_if url.blank?, 'No FHIR server URL provided'\n      summary_op_defined?\n      " \
                  "operation_defined?(operations, 'http://hl7.org/fhir/uv/ipa/OperationDefinition/docref', " \
                  "%w[docref],\n                         :docref_op_defined)"
      },
      {
        file_base: 'au_ps_cs_supports_au_ps_profiles',
        class_base: 'AUPSCSSupportsAUPSProfiles',
        id_base: 'au_ps_cs_supports_au_ps_profiles',
        title: 'CapabilityStatement supports AU PS Profiles',
        description: 'AU PS Profiles referenced as supported in CapabilityStatement',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'AU PS Profiles referenced as supported in CapabilityStatement',
        run_code: nil,
        custom_template: 'cs_supports_au_ps_profiles_test.rb.erb'
      }
    ].freeze
  end
end
