# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/constants'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class AUPSBundleIsValidTest < BasicTest
    id :au_ps_bundle_is_valid_test
    title t_title(:au_ps_bundle_is_valid_test)
    description t_description(:au_ps_bundle_is_valid_test)

    input :bundle_resource,
          optional: true,
          description: 'If you want to check existing Bundle resource',
          type: 'textarea'

    def skip_test?
      bundle_resource.blank?
    end

    def get_and_save_data
      info 'Validate provided Bundle resource'
      resource = FHIR.from_contents(bundle_resource)
      scratch[:bundle_ips_resource] = resource
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    run do
      skip_if skip_test?, 'No Bundle resource provided'
      get_and_save_data
      validate_ips_bundle
    end
  end
end
