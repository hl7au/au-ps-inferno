# frozen_string_literal: true

require_relative 'bundle_is_valid_class'

module AUPSTestKit
  # The Bundle resource is valid against the IPS Bundle profile
  class IpsBundleIsValidClass < BundleIsValidClass
    id :ips_bundle_is_valid_class_base

    run do
      skip_if skip_test?, 'No Bundle resource provided'
      read_and_save_data
      omit_if !ips_bundle_validation_enabled?, 'IPS Bundle validation is disabled'
      validate_ips_bundle
    end
  end
end
