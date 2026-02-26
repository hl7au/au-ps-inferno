# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated test for History of Pregnancy section validation
  class AUPSSectionsHistoryofPregnancyValidation100preview < BasicTest
    title 'Validate History of Pregnancy Section References and Resources'
    description 'Validates that the History of Pregnancy section in the Composition resource contains valid ' \
                'references that resolve to expected resource types in the bundle, and that each ' \
                'referenced resource conforms to its specified FHIR profile(s).'
    id :au_ps_sections_history_of_pregnancy_validation_100preview
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
      validate_section_resources({"code"=>"10162-6", "display"=>"Patient Summary History of Pregnancy Section", "resources"=>{"Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips"=>{"requirements"=>[{"path"=>"code.coding.code", "value"=>"82810-3"}]}, "Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-outcome-uv-ips"=>{"requirements"=>[{"path"=>"code.coding.code", "value"=>["11636-8", "11637-6", "11638-4", "11639-2", "11640-0", "11612-9", "11613-7", "11614-5", "33065-4"]}]}}})
    end
  end
end
