# frozen_string_literal: true

require_relative 'summary_valid_bundle_class'

module AUPSTestKit
  # Bundle from $summary validated against the IPS Bundle profile
  class IpsSummaryValidBundleClass < SummaryValidBundleClass
    id :ips_summary_valid_bundle_class_base

    run do
      skip_if url.blank?, 'No FHIR server specified'
      summary_op_defined? if scratch[:summary_op_defined].blank?
      skip_if scratch[:summary_op_defined] == false, 'Server does not declare support for $summary operation'
      read_and_save_data
      omit_if omit_ips_validation?, OMIT_IPS_MESSAGE
      validate_ips_bundle
    end
  end
end
