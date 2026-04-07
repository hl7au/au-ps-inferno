# frozen_string_literal: true

require_relative '../basic_test_contants_module'

module AUPSTestKit
  # Inferno tests for Composition.custodian Must Support.
  module BasicTestCustodianTests
    include BasicTestConstants

    def test_composition_custodian_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = custodian_resource
      skip_if resource.blank?, 'Custodian is not populated'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_custodian_ms_identifier_slices(resource, ORGANIZATION_MS_IDENTIFIER_SLICES, rtype_str, profile_str)
    end
  end
end
