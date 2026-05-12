# frozen_string_literal: true

module AUPSTestKit
  # Basic test for validating a Bundle resource against the AU PS Bundle or IPS Bundle profile
  class BasicValidateBundleTest < BasicTest
    OMIT_AU_PS_MESSAGE = 'Validation against AU PS Bundle is disabled'
    OMIT_IPS_MESSAGE = 'Validation against IPS Bundle is disabled'

    id :basic_validate_bundle_test

    input :validate_against,
          title: 'Validate Against',
          optional: true,
          type: 'checkbox',
          default: %w[au_ps_bundle],
          options: {
            list_options: [
              {
                label: 'AU PS Bundle Validation',
                value: 'au_ps_bundle'
              },
              {
                label: 'IPS Bundle Validation',
                value: 'ips_bundle'
              }
            ]
          }

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
