# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/bundle_is_valid_class'

require_relative '../../../utils/ips_bundle_is_valid_class'

module AUPSTestKit
  # Automatically generated primitive test for Bundle is valid against AU PS Bundle
  class AUPSSuite100previewAuPsBundleInstanceBundleValidationBundleIsValidAgainstAuPsBundle < BundleIsValidClass
    title 'Bundle is valid against AU PS Bundle'
    description 'The Bundle resource is valid against the AU PS Bundle profile using FHIR validator'
    id :suite_100preview_au_ps_bundle_instance_bundle_validation_bundle_valid

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end
  end
end
