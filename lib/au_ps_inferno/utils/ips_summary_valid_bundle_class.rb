# frozen_string_literal: true

require_relative 'summary_valid_bundle_class'

module AUPSTestKit
  # Bundle from $summary validated against the IPS Bundle profile
  class IpsSummaryValidBundleClass < SummaryValidBundleClass
    id :ips_summary_valid_bundle_class_base

    run do
      omit_if omit_ips_validation?, OMIT_IPS_MESSAGE
      validate_ips_bundle
    end
  end
end
