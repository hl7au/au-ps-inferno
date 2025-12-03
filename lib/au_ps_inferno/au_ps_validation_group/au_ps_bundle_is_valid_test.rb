# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/constants'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class AUPSBundleIsValidTest < BasicTest
    id :au_ps_bundle_is_valid_test
    title 'AU PS Bundle is valid'
    description 'Validates that a Bundle resource conforms to the AU PS Bundle profile ' \
      '(http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle). The test accepts a pre-existing '\
      'Bundle resource to validate directly.'

    input :bundle_resource,
          optional: true,
          description: 'If you want to check existing Bundle resource',
          type: 'textarea'

    def skip_test?
      bundle_resource.blank?
    end

    def read_and_save_data
      info 'Validate provided Bundle resource'
      resource = FHIR.from_contents(bundle_resource)
      scratch[:bundle_ips_resource] = resource
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    run do
      skip_if skip_test?, 'No Bundle resource provided'
      read_and_save_data
      validate_ips_bundle
    end
  end
end
