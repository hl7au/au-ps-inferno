# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-elements SHALL be populated if a value is known
  class AUPSSuiteAuPsBundleInstanceAuPsCompositionAuthorMustSupportSubelementsShallBePopulatedIfAValueIsKnown100ballot < BasicTest
    title 'Must Support sub-elements SHALL be populated if a value is known'
    description 'Must Support sub-elements SHALL be populated if a value is known'
    id :suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_subelements_100ballot

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end

    run do
      ms_sub_elements_populated_message('author')
    end
  end
end
