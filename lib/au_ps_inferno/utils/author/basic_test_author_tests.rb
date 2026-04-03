# frozen_string_literal: true

require_relative '../basic_test_contants_module'

module AUPSTestKit
  # Inferno tests for Composition.author Must Support.
  module BasicTestAuthorTests
    include BasicTestConstants

    def test_composition_author_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = author_resource
      skip_if resource.blank?, 'No author reference found on Composition'

      resource_type_str = resource_type(resource)
      skip_if resource_type_str == 'Device', 'Referenced author resource type is Device'
      slices = AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE[resource_type_str] || []
      skip_if slices.blank?,
              'No Must Support identifier slices are defined for the referenced author type (e.g. AU PS RelatedPerson)'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_author_ms_identifier_slices(resource, slices, rtype_str, profile_str)
    end
  end
end
