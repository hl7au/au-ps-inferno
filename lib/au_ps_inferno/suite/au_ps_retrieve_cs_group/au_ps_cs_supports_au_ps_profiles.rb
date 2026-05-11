# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/capability_statement_decorator'

module AUPSTestKit
  # Verifies that the CapabilityStatement declares support for the required AU PS profiles.
  class AUPSCSSupportsAUPSProfiles100preview < BasicTest
    title 'CapabilityStatement supports AU PS Profiles'
    description 'Verifies that the CapabilityStatement declares support for the required AU PS profiles.'
    id :au_ps_cs_supports_au_ps_profiles_100preview

    def check_profiles_status(profiles_mapping, general_message)
      au_ps_profiles_status_array = profiles_mapping.keys.map do |profile_url|
        "#{profiles_mapping[profile_url]} (#{profile_url}): #{cs_profiles.include?(profile_url) ? 'Yes' : 'No'}"
      end.join("\n\n")
      info "**#{general_message}**:\n\n#{au_ps_profiles_status_array}"
    end

    def cs_profiles
      cs_resource = CapabilityStatementDecorator.new(scratch[:capability_statement].to_hash)
      cs_resource.all_profiles
    end

    run do
      skip_if scratch[:capability_statement].blank?, 'No CapabilityStatement resource provided'
      check_profiles_status(
        {"http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance"=>"AUPSAllergyIntolerance", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle"=>"AUPSBundle", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition"=>"AUPSComposition", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition"=>"AUPSCondition", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest"=>"AUPSMedicationRequest", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement"=>"AUPSMedicationStatement", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient"=>"AUPSPatient"},
        'For each of the following AU PS profiles indicate if it is referenced as a supported profile'
      )

      check_profiles_status(
        {"http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path"=>"AUPSPathologyResult", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter"=>"AUPSEncounter", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization"=>"AUPSImmunization", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication"=>"AUPSMedication", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization"=>"AUPSOrganization", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner"=>"AUPSPractitioner", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole"=>"AUPSPractitionerRole", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure"=>"AUPSProcedure", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson"=>"AUPSRelatedPerson", "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-smokingstatus"=>"AUPSSmokingStatus"},
        'List any other AU PS profiles referenced as supported profile'
      )
    end
  end
end
