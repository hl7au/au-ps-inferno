# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition Optional Sections capable of populating referenced profiles
  class AUPSSuiteGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionOptionalSectionsAuPsCompositionOptionalSectionsCapableOfPopulatingReferencedProfiles < BasicTest
    title 'AU PS Composition Optional Sections capable of populating referenced profiles'
    description 'Optional section SHALL be capable of populating section.entry with the referenced profiles and SHOULD correctly populate section.entry if a value is known.'
    id :suite_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_optional_sections_optional_sections_entry_profiles
    optional

    run do
      test_composition_optional_sections
    end
  end
end
