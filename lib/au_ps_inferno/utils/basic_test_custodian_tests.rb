# frozen_string_literal: true

require_relative 'basic_test_contants_module'

module AUPSTestKit
  # Inferno tests for Composition.custodian Must Support.
  module BasicTestCustodianTests
    include BasicTestConstants

    def test_composition_custodian_ms_elements
      resource = composition_custodian_resource_for_ms_tests
      custodian_meta = composition_custodian_metadata
      skip_if custodian_meta.blank?, 'No custodian metadata available'

      elements_config = custodian_complex_ms_elements(custodian_meta)
      skip_if elements_config.blank?, 'No complex Must Support elements defined for custodian'

      validate_custodian_ms_elements(resource, elements_config)
    end

    def test_composition_custodian_ms_subelements
      resource = composition_custodian_resource_for_ms_tests
      custodian_meta = composition_custodian_metadata
      skip_if custodian_meta.blank?, 'No custodian metadata available'

      parent_groups = custodian_ms_subelement_parent_groups(custodian_meta)
      skip_if parent_groups.blank?, 'No complex elements with Must Support sub-elements defined for custodian'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_custodian_ms_subelements(resource, parent_groups, rtype_str, profile_str)
    end

    def test_composition_custodian_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = custodian_resource
      skip_if resource.blank?, 'Custodian is not populated'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_custodian_ms_identifier_slices(resource, ORGANIZATION_MS_IDENTIFIER_SLICES, rtype_str, profile_str)
    end

    private

    def composition_custodian_resource_for_ms_tests
      check_bundle_exists_in_scratch
      resource = custodian_resource
      skip_if resource.blank?, 'Custodian is not populated'
      resource
    end
  end
end
