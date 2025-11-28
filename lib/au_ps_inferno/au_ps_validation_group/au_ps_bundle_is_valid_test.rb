# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/constants'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  class AUPSBundleIsValidTest < BasicTest
    title TEXTS[:au_ps_bundle_is_valid_test][:title]
    description TEXTS[:au_ps_bundle_is_valid_test][:description]
    id :au_ps_bundle_is_valid_test

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
      scratch[:ips_bundle_resource] = resource
      info "Bundle resource saved to scratch: #{scratch[:ips_bundle_resource]}"
    end

    run do
      skip_if skip_test?, 'No Bundle resource provided'
      get_and_save_data
      validate_bundle(
        scratch[:ips_bundle_resource],
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.4.0-draft')
    end
  end
end
