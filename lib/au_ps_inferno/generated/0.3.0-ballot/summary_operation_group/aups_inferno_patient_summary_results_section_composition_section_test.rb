# frozen_string_literal: true

module AUPSTestKit
  class AUPSInfernoPatientSummaryResultsSectionCompositionSectionTest < Inferno::Test
    title 'Validate Patient Summary Results Section'
    description 'This test verifies that the Patient Summary Results Section within the Composition entry of a $summary Bundle is correctly structured. It extracts the references listed in the section, checks that the corresponding resources exist in the Bundle, and ensures they conform to the expected resource type and profile requirements.'
    id :au_ps_patient_summary_results_section_composition_section_test
    
    optional
    
    uses_request :summary_operation

    run do
      composition_entry = resource.entry.find { |r| r.resource.resourceType == 'Composition' }
      skip_if !composition_entry, "Composition entry does not exist"

      composition_resource = composition_entry.resource
      current_section = composition_resource.section.find { |s| s.code.coding.first.code == '30954-2' }
      skip_if !current_section, "Section does not exist"
      skip_if !current_section.entry, "Section entry does not exist"
      skip_if current_section.entry.length == 0, "Section entry count is 0"

      section_entries_refs = current_section.entry.map { |e| e.reference }

      target_resources_and_profiles = 'Observation::http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path;Observation::http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-results-radiology-uv-ips;DiagnosticReport::http://hl7.org/fhir/uv/ips/StructureDefinition/DiagnosticReport-uv-ips'.split(';').map do |segment|
        resource, profiles = segment.split('::')
        {
          resource: resource,
          profiles: profiles&.split(',')&.reject(&:empty?) || []
        }
      end

      existing_resources = section_entries_refs.map { |ref| resource.entry.find { |e| e.fullUrl == ref } }.compact

      filtered_existing_resources = existing_resources.select do |er|
        target_resource = target_resources_and_profiles.find { |trp| trp[:resource] == er.resource.resourceType }
        target_resource && target_resource[:profiles].any? { |profile| er.resource.meta&.profile&.include?(profile) }
      end

      assert section_entries_refs.length == filtered_existing_resources.length, "Incorrect number of entries: expected #{section_entries_refs.length}, found #{filtered_existing_resources.length}"
    end
  end
end
