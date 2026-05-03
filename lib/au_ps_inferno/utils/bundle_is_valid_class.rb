# frozen_string_literal: true

require_relative 'basic_validate_bundle_test'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class BundleIsValidClass < BasicValidateBundleTest
    id :bundle_is_valid_class_test
    input :bundle_resource,
          optional: true,
          description: 'If you want to check existing Bundle resource',
          type: 'textarea'

    def skip_test?
      bundle_resource.blank?
    end

    def omit_test?
      validate_against.blank? || !validate_against.include?('au_ps_bundle')
    end

    def read_and_save_data
      info 'Reading and saving provided Bundle resource'
      resource = FHIR.from_contents(bundle_resource)
      scratch[:bundle_ips_resource] = resource
      save_bundle_entities_to_scratch(scratch_bundle)
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    run do
      skip_if skip_test?, 'No Bundle resource provided'
      read_and_save_data
      omit_if omit_test?, 'Validation against AU PS Bundle is disabled'
      validate_au_ps_bundle
    end
  end
end
