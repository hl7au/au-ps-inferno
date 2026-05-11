# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition Mandatory Sections capable of populating referenced profiles
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsAuPsCompositionMandatorySectionsAuPsCompositionMandatorySectionsCapableOfPopulatingReferencedProfiles < BasicTest
    title 'AU PS Composition Mandatory Sections capable of populating referenced profiles'
    description 'Mandatory section SHALL be capable of populating section.entry with the referenced profiles and SHOULD correctly populate section.entry if a value is known.'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections_mandatory_sections_entry_profiles

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end

    run do
      test_composition_mandatory_sections
    end
  end
end
