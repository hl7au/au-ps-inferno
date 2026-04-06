# frozen_string_literal: true

require_relative '../basic_test_contants_module'

module AUPSTestKit
  # Inferno tests for Composition.author Must Support.
  module BasicTestAuthorTests
    include BasicTestConstants

    def test_composition_author_ms_identifier_slices
      resource_is_poluated = raw_resource_type_is_valid('author')
      skip_if !resource_is_poluated[:valid?], resource_is_poluated[:msg]

      resource = author_resource
      resource_type_str = resource_type(resource)
      skip_if resource_type_str == 'Device', 'Referenced author resource type is Device'
      slices = AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE[resource_type_str] || []
      skip_if slices.blank?,
              'No Must Support identifier slices are defined for the referenced author type (e.g. AU PS RelatedPerson)'

      # rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_ms_identifier_slices_in_resource(resource, slices)
    end
  end
end
