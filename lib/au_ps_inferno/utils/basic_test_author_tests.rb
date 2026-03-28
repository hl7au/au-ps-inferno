# frozen_string_literal: true

require_relative 'basic_test_contants_module'

module AUPSTestKit
  # Inferno tests for Composition.author Must Support.
  module BasicTestAuthorTests
    include BasicTestConstants

    def test_composition_author_ms_elements
      resource = composition_author_resource_for_ms_tests(
        'Referenced author entry is type of Device; skip Must Support validation'
      )
      author_meta = composition_author_metadata
      skip_if author_meta.blank?, 'No author metadata available'

      resource_type_str = resource_type(resource)
      complex_elements = author_complex_ms_elements_for_type(author_meta, resource_type_str)
      skip_if complex_elements.blank?, "No complex Must Support elements defined for author type #{resource_type_str}"

      validate_author_ms_elements(resource, complex_elements)
    end

    def test_composition_author_ms_subelements
      resource = composition_author_resource_for_ms_tests('Referenced author resource type is Device')
      author_meta = composition_author_metadata
      skip_if author_meta.blank?, 'No author metadata available'

      resource_type_str = resource_type(resource)
      parent_groups = author_ms_subelement_parent_groups(author_meta, resource_type_str)
      skip_if parent_groups.blank?,
              'Referenced author resource type has no complex elements with Must Support sub-elements'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_author_ms_subelements(resource, parent_groups, rtype_str, profile_str)
    end

    def test_composition_author_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = author_resource
      skip_if resource.blank?, 'No author reference found on Composition'
      skip_if resource_type(resource) == 'Device', 'Referenced author resource type is Device'

      resource_type_str = resource_type(resource)
      slices = AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE[resource_type_str] || []
      skip_if slices.blank?,
              'No Must Support identifier slices are defined for the referenced author type (e.g. AU PS RelatedPerson)'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_author_ms_identifier_slices(resource, slices, rtype_str, profile_str)
    end

    private

    def composition_author_resource_for_ms_tests(device_skip_message)
      check_bundle_exists_in_scratch
      resource = author_resource
      skip_if resource.blank?, 'No author reference found on Composition'
      skip_if resource_type(resource) == 'Device', device_skip_message
      resource
    end
  end
end
