# frozen_string_literal: true

require_relative '../basic_test_contants_module'

module AUPSTestKit
  # Inferno tests for Composition.author Must Support.
  module BasicTestAuthorTests
    include BasicTestConstants

    def test_composition_author_ms_identifier_slices
      guard_populated_resource('author')

      resource = author_resource
      author_and_device_resource?('author', resource)

      resource_type_str = resource_type(resource)
      slices = AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE[resource_type_str] || []
      omit_if slices.blank?,
              'No Must Support identifier slices are defined for the referenced author type (e.g. AU PS RelatedPerson)'

      # rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_ms_identifier_slices_in_resource(resource, slices)
    end
  end
end
