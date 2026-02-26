# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated test for Results section validation
  class AUPSSectionsResultsValidation100preview < BasicTest
    title 'Validate Results Section References and Resources'
    description 'Validates that the Results section in the Composition resource contains valid ' \
                'references that resolve to expected resource types in the bundle, and that each ' \
                'referenced resource conforms to its specified FHIR profile(s).'
    id :au_ps_sections_results_validation_100preview
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
      validate_section_resources({"code"=>"30954-2", "display"=>"Patient Summary Results Section", "resources"=>{"Observation|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path"=>{"requirements"=>[{"path"=>"category.coding.code", "value"=>"laboratory"}]}, "Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-results-radiology-uv-ips"=>{"requirements"=>[{"path"=>"category.coding.code", "value"=>"imaging"}]}, "DiagnosticReport|http://hl7.org/fhir/uv/ips/StructureDefinition/DiagnosticReport-uv-ips"=>{"requirements"=>[]}}})
    end
  end
end
