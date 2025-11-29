# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The Must Support elements populated in the Bundle resource.
  class AUPSSummaryBundleHasMUSTSUPPORTElements < BasicTest
    title t_title(:au_ps_summary_bundle_has_must_support_elements)
    description t_description(:au_ps_summary_bundle_has_must_support_elements)
    id :au_ps_summary_bundle_has_must_support_elements

    run do
      bundle_mandatory_ms_elements_info
    end
  end
end
