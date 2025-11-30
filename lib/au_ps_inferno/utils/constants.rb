# frozen_string_literal: true

# Common constants used in tests
module Constants
  MANDATORY_MS_ELEMENTS = [
    { expression: '$.status', label: 'status' },
    { expression: '$.type', label: 'type' },
    { expression: '$.subject.reference', label: 'subject.reference' },
    { expression: '$.date', label: 'date' },
    { expression: '$.author[0]', label: 'author' },
    { expression: '$.title', label: 'title' }
  ].freeze

  OPTIONAL_MS_ELEMENTS = [
    { expression: '$.text', label: 'text' },
    { expression: '$.identifier', label: 'identifier' },
    { expression: '$.attester', label: 'asserter' },
    { expression: '$.attester.mode', label: 'asserter.mode' },
    { expression: '$.attester.time', label: 'asserter.time' },
    { expression: '$.attester.party', label: 'asserter.party' },
    { expression: '$.custodian', label: 'custodian' },
    { expression: '$.event.code.coding.code', label: 'event' },
    { expression: '$.event.code', label: 'event.code' },
    { expression: '$.event.period', label: 'event.period' }
  ].freeze

  MANDATORY_SECTIONS = %w[11450-4 48765-2 10160-0].freeze
  RECOMMENDED_SECTIONS = %w[11369-6 30954-2 47519-4 46264-8].freeze
  OPTIONAL_SECTIONS = %w[42348-3 104605-1 47420-5 11348-0 10162-6 81338-6 18776-5 29762-2 8716-3].freeze
  ALL_SECTIONS = (MANDATORY_SECTIONS + RECOMMENDED_SECTIONS + OPTIONAL_SECTIONS).freeze

  AU_PS_PROFILES_MAPPING_REQUIRED = {
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle' => 'AU PS Bundle',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition' => 'AU PS Composition',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient' => 'AU PS Patient',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition' => 'AU PS Condition',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance' => 'AU PS AllergyIntolerance',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement' => 'AU PS MedicationStatement',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest' => 'AU PS MedicationRequest'
  }.freeze

  AU_PS_PROFILES_MAPPING_OTHER = {
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter' => 'AU PS Encounter',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization' => 'AU PS Immunization',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication' => 'AU PS Medication',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path' =>
      'AU PS Pathology Result Observation',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-smokingstatus' => 'AU PS Smoking Status',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization' => 'AU PS Organization',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner' => 'AU PS Practitioner',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole' => 'AU PS PractitionerRole',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure' => 'AU PS Procedure',
    'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson' => 'AU PS RelatedPerson'
  }.freeze
end
