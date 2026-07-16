# frozen_string_literal: true

require_relative 'basic_validate_bundle_test'
require_relative 'common_inputs_module'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class BundleIsValidClass < BasicValidateBundleTest
    id :bundle_is_valid_class_test
    CommonInputsModule.shared_inputs(self)

    def skip_test?
      scratch_bundle.blank? && bundle_resource.blank?
    end

    def read_and_save_data
      resource = FHIR.from_contents(bundle_resource)
      scratch[:bundle_ips_resource] = resource
      save_bundle_entities_to_scratch(scratch_bundle)
    end

    run do
      omit_if skip_test?, 'No Bundle resource provided'
      read_and_save_data if scratch_bundle.blank?
      omit_if omit_au_ps_validation?, OMIT_AU_PS_MESSAGE
      validate_au_ps_bundle
    end
  end
end
