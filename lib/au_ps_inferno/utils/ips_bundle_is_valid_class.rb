# frozen_string_literal: true

require_relative 'bundle_is_valid_class'

module AUPSTestKit
  # The Bundle resource is valid against the IPS Bundle profile
  class IpsBundleIsValidClass < BundleIsValidClass
    id :ips_bundle_is_valid_class_base

    run do
      omit_if omit_ips_validation?, OMIT_IPS_MESSAGE
      validate_ips_bundle
    end
  end
end
