# frozen_string_literal: true

require 'json'
require 'fhir_models'

# Builds minimal {FHIR::StructureDefinition} arrays for {Generator::MetadataManager} specs.
# rubocop:disable Metrics/ModuleLength, Metrics/MethodLength -- compact FHIR fixture builders
module GeneratorMetadataManagerFixtures
  module_function

  def device_uv_ips_from_additional_resources
    path = File.expand_path('../../additional_resources/StructureDefinition-Device-uv-ips.json', __dir__)
    FHIR.from_contents(File.read(path))
  end

  def minimal_sd(type:, url:, name:, title: nil)
    {
      'resourceType' => 'StructureDefinition',
      'url' => url,
      'name' => name,
      'title' => title || name,
      'type' => type,
      'snapshot' => {
        'element' => [
          { 'id' => type, 'path' => type, 'min' => 0, 'max' => '*', 'mustSupport' => true }
        ]
      }
    }
  end

  def parse_sd(hash)
    FHIR.from_contents(JSON.generate(hash))
  end

  # AU PS Composition with one problem section, MS on subject/custodian, and an attester slice (for slice metadata).
  def composition_sd_hash
    {
      'resourceType' => 'StructureDefinition',
      'url' => 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition',
      'name' => 'AUPSComposition',
      'title' => 'AU PS Composition',
      'type' => 'Composition',
      'snapshot' => {
        'element' => [
          { 'id' => 'Composition', 'path' => 'Composition', 'min' => 0, 'max' => '*' },
          {
            'id' => 'Composition.subject',
            'path' => 'Composition.subject',
            'min' => 1,
            'max' => '1',
            'mustSupport' => true
          },
          {
            'id' => 'Composition.custodian',
            'path' => 'Composition.custodian',
            'min' => 0,
            'max' => '1',
            'mustSupport' => true
          },
          {
            'id' => 'Composition.attester:legal',
            'path' => 'Composition.attester',
            'sliceName' => 'legal',
            'min' => 1,
            'max' => '*',
            'mustSupport' => true
          },
          {
            'id' => 'Composition.attester:legal.party',
            'path' => 'Composition.attester.party',
            'min' => 1,
            'max' => '1',
            'mustSupport' => true
          },
          {
            'id' => 'Composition.section:sectionProblems',
            'path' => 'Composition.section',
            'sliceName' => 'sectionProblems',
            'min' => 1,
            'max' => '1',
            'short' => 'Problems',
            'definition' => 'Problems section',
            'mustSupport' => true
          },
          {
            'id' => 'Composition.section.title',
            'path' => 'Composition.section.title',
            'min' => 1,
            'max' => '1',
            'mustSupport' => true
          },
          {
            'id' => 'Composition.section.text',
            'path' => 'Composition.section.text',
            'min' => 1,
            'max' => '1',
            'mustSupport' => true
          },
          {
            'id' => 'Composition.section:sectionProblems.code',
            'path' => 'Composition.section.code',
            'min' => 1,
            'max' => '1',
            'mustSupport' => true,
            'patternCodeableConcept' => {
              'coding' => [{ 'system' => 'http://loinc.org', 'code' => '11450-4' }]
            }
          },
          {
            'id' => 'Composition.section:sectionProblems.entry:problem',
            'path' => 'Composition.section.entry',
            'sliceName' => 'problem',
            'min' => 0,
            'max' => '*',
            'mustSupport' => true,
            'type' => [{
              'code' => 'Reference',
              'targetProfile' => ['http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition']
            }]
          }
        ]
      }
    }
  end

  # Full IG: mappings, required profiles, and Device (IPS) for author metadata.
  def full_ig_resources
    au = 'http://hl7.org.au/fhir/ps/StructureDefinition'
    extras = [
      minimal_sd(type: 'Condition', url: "#{au}/au-ps-condition", name: 'AUPSCondition'),
      minimal_sd(type: 'Bundle', url: "#{au}/au-ps-bundle", name: 'AUPSBundle'),
      minimal_sd(type: 'Patient', url: "#{au}/au-ps-patient", name: 'AUPSPatient'),
      minimal_sd(type: 'AllergyIntolerance', url: "#{au}/au-ps-allergyintolerance", name: 'AUPSAllergyIntolerance'),
      minimal_sd(type: 'MedicationStatement', url: "#{au}/au-ps-medicationstatement", name: 'AUPSMedicationStatement'),
      minimal_sd(type: 'MedicationRequest', url: "#{au}/au-ps-medicationrequest", name: 'AUPSMedicationRequest'),
      minimal_sd(type: 'Organization', url: "#{au}/au-ps-organization", name: 'AUPSOrganization'),
      minimal_sd(type: 'RelatedPerson', url: "#{au}/au-ps-relatedperson", name: 'AUPSRelatedPerson'),
      minimal_sd(type: 'Practitioner', url: "#{au}/au-ps-practitioner", name: 'AUPSPractitioner'),
      minimal_sd(type: 'PractitionerRole', url: "#{au}/au-ps-practitionerrole", name: 'AUPSPractitionerRole'),
      minimal_sd(type: 'Immunization', url: "#{au}/au-ps-immunization", name: 'AUPSImmunization')
    ].map { |h| parse_sd(h) }

    [parse_sd(composition_sd_hash), *extras, device_uv_ips_from_additional_resources]
  end
end
# rubocop:enable Metrics/ModuleLength, Metrics/MethodLength
