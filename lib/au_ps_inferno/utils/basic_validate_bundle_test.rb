# frozen_string_literal: true

module AUPSTestKit
  # Basic test for validating a Bundle resource against the AU PS Bundle or IPS Bundle profile
  class BasicValidateBundleTest < BasicTest
    id :basic_validate_bundle_test

    input :validate_against,
          title: 'Validate Against',
          optional: true,
          type: 'checkbox',
          default: ['au_ps_bundle'],
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
  end
end
