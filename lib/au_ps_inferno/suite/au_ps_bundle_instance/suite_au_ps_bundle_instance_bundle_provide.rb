# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/metadata_manager'

require_relative '../../utils/provided_bundle_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Load the provided AU PS Bundle
  class AUPSSuiteAuPsBundleInstanceBundleValidationLoadTheProvidedAuPsBundle < ProvidedBundleTestClass
    title 'Load the provided AU PS Bundle'
    description 'Parses the Bundle resource pasted as text and stores it for the validation tests in this group.'
    id :suite_au_ps_bundle_instance_bundle_provide

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end
  end
end
