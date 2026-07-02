# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition Mandatory Sections capable of populating referenced profiles
  class AUPSSuiteGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionMandatorySectionsAuPsCompositionMandatorySectionsCapableOfPopulatingReferencedProfiles100ballot < BasicTest
    title 'AU PS Composition Mandatory Sections capable of populating referenced profiles'
    description 'Mandatory section SHALL be capable of populating section.entry with the referenced profiles and SHOULD correctly populate section.entry if a value is known.'
    id :suite_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections_mandatory_sections_entry_profiles_100ballot

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end

    run do
      test_composition_mandatory_sections
    end
  end
end
