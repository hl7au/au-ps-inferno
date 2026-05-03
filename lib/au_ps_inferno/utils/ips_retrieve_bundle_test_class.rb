# frozen_string_literal: true

require_relative 'retrieve_bundle_test_class'

module AUPSTestKit
  # Retrieve a bundle and validate against the IPS Bundle profile
  class IpsRetrieveBundleTestClass < RetrieveBundleTestClass
    id :ips_retrieve_bundle_test_class_base

    run do
      skip_if skip_test?, 'There is no FHIR server URL, Bundle ID or Bundle URL provided'
      read_and_save_data
      omit_if !ips_bundle_validation_enabled?, 'IPS Bundle validation is disabled'
      validate_ips_bundle
    end
  end
end
