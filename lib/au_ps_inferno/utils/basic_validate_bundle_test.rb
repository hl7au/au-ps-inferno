# frozen_string_literal: true

require_relative 'common_inputs_module'

module AUPSTestKit
  # Basic test for validating a Bundle resource against the AU PS Bundle or IPS Bundle profile
  class BasicValidateBundleTest < BasicTest
    OMIT_AU_PS_MESSAGE = 'Validation against the AU PS Bundle profile is disabled because "AU PS Bundle ' \
                         'Validation" is not selected in the "Validate Against" input.'
    OMIT_IPS_MESSAGE = 'Validation against the IPS Bundle profile is disabled because "IPS Bundle ' \
                       'Validation" is not selected in the "Validate Against" input.'

    id :basic_validate_bundle_test

    CommonInputsModule.validate_against_input(self)

    def omit_au_ps_validation?
      omit_test_wrapper?('au_ps_bundle')
    end

    def omit_ips_validation?
      omit_test_wrapper?('ips_bundle')
    end

    private

    def omit_test_wrapper?(include_str)
      validate_against.blank? || !validate_against.include?(include_str)
    end
  end
end
