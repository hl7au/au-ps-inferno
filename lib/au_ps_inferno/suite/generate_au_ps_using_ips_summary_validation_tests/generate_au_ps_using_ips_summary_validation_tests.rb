# frozen_string_literal: true

require_relative 'bundle_acquisition'

require_relative '../../utils/common_inputs_module'

module AUPSTestKit
  # Automatically generated high order group for Generate AU PS using IPS $summary validation tests
  class AUPSSuiteGenerateAuPsUsingIpsSummaryValidationTests < Inferno::TestGroup
    title 'Generate and retrieve Bundle via $summary'
    description 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle'
    id :suite_generate_au_ps_using_ips_summary_validation_tests

    run_as_group

    CommonInputsModule.shared_inputs(self)

    group from: :suite_generate_au_ps_using_ips_summary_validation_tests_bundle_acquisition
  end
end
