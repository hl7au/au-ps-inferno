# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/metadata_manager'

require_relative '../../utils/provided_bundle_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Bundle instance is parsable
  class AUPSSuiteAuPsBundleInstanceBundleValidationLoadTheProvidedAuPsBundle < ProvidedBundleTestClass
    title 'Bundle instance is parsable'
    description 'The provided text can be parsed as a FHIR resource (JSON or XML) and its resourceType is ' \
                'Bundle. The parsed Bundle is stored for the validation tests in this group; conformance to the ' \
                'AU PS Bundle profile is tested separately under Bundle Validation.'
    id :suite_au_ps_bundle_instance_bundle_provide

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end
  end
end
