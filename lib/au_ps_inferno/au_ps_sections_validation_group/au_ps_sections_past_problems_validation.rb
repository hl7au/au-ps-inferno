# frozen_string_literal: true

require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The optional sections populated in the Composition resource.
  class AUPSSectionsPastProblemsValidation < BasicTest
    title 'Validate HISTORY OF PAST ILLNESS NOTE Section References and Resources'
    description 'Validates that the HISTORY OF PAST ILLNESS NOTE section in the Composition resource contains valid references that resolve to expected resource types in the bundle, and that each referenced resource conforms to its specified FHIR profile(s).'
    id :au_ps_sections_past_problems_validation
    optional true

    input :bundle_resource,
          optional: true,
          description: 'If you want to check existing Bundle resource',
          type: 'textarea'

    def skip_test?
      bundle_resource.blank?
    end

    def read_and_save_data
      resource = FHIR.from_contents(bundle_resource)
      scratch[:bundle_ips_resource] = resource
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    run do
      skip_if skip_test?, 'No Bundle resource provided'
      read_and_save_data
      validate_section_resources('HISTORY_OF_PAST_ILLNESS_NOTE')
    end
  end
end
