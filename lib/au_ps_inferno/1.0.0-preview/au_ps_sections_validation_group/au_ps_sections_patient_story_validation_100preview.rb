# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated test for Patient Story section validation
  class AUPSSectionsPatientStoryValidation100preview < BasicTest
    title 'Validate Patient Story Section References and Resources'
    description 'Validates that the Patient Story section in the Composition resource contains valid ' \
                'references that resolve to expected resource types in the bundle, and that each ' \
                'referenced resource conforms to its specified FHIR profile(s).'
    id :au_ps_sections_patient_story_validation_100preview
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
      validate_section_resources({"code"=>"81338-6", "display"=>"Patient Summary Patient Story Section", "resources"=>{}})
    end
  end
end
