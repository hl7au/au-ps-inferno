# frozen_string_literal: true

module AUPSTestKit
  class AUPSInfernoIPSAllergiesandIntolerancesSectionCompositionSectionTest < Inferno::Test
    title 'Validate IPS Allergies and Intolerances Section'
    description 'This test verifies that the IPS Allergies and Intolerances Section within the Composition entry of a $summary Bundle is correctly structured. It extracts the references listed in the section, checks that the corresponding resources exist in the Bundle, and ensures they conform to the expected resource type and profile requirements.'
    id :au_ps_ips_allergies_and_intolerances_section_composition_section_test
    
    uses_request :summary_operation

    run do
      composition_entry = resource.entry.find { |r| r.resource.resourceType == 'Composition' }
      skip_if !composition_entry, "Composition entry does not exists"

      composition_resource = composition_entry.resource
      current_section = composition_resource.section.find { |s| s.code.coding.first.code == '48765-2' }
      skip_if !current_section, "Section does not exists"
      skip_if !current_section.entry, "Section entry does not exists"

      section_entries_refs = current_section.entry.map { |e| e.reference }
      target_resources_and_profiles = 'AllergyIntolerance::http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance'.split(';').map do |segment|
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

      info "#{section_entries_refs}"
      info "#{target_resources_and_profiles}"
      info "#{existing_resources}"
      info "#{filtered_existing_resources}"

      assert section_entries_refs.length == filtered_existing_resources.length, "TODO: Incorrect number of entries"
    end
  end
end
