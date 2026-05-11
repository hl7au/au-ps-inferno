# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition optional sections are correctly populated
  class AUPSSuite100previewAuPsBundleInstanceAuPsCompositionOptionalSectionsAuPsCompositionOptionalSectionsAreCorrectlyPopulated < BasicTest
    title 'AU PS Composition optional sections are correctly populated'
    description 'Optional section MAY be correctly populated if a value is known'
    id :suite_100preview_au_ps_bundle_instance_au_ps_composition_optional_sections_sections_may_populated

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end

    run do
      validate_populated_sections_in_bundle(
        %w[42348-3 104605-1 47420-5 11348-0 10162-6 81338-6 18776-5 29762-2
           8716-3], %w[title code text], optional: true
      )
    end
  end
end
