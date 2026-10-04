# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Must Support elements SHALL be populated if a value is known
  class AUPSSuiteGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionAuthorMustSupportElementsShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support elements SHALL be populated if a value is known'
    description 'Must Support elements SHALL be populated if a value is known'
    id :suite_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author_author_ms_elements

    run do
      ms_elements_populated_message('author')
    end
  end
end
