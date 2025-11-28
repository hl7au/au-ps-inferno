# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  class AUPSBundleHasMUSTSUPPORTElements < BasicTest
    title 'Bundle has mandatory must-support elements'
    description 'Checks that the Bundle resource contains mandatory must-support elements (identifier, type, timestamp) and that all entries have a fullUrl. Also provides information about the resource types included in the Bundle.'
    id :au_ps_bundle_has_must_support_elements

    run do
      bundle_mandatory_ms_elements_info
    end
  end
end
