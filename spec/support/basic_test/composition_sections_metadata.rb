# frozen_string_literal: true

module CompositionSectionsMetadata # rubocop:disable Metrics/ModuleLength
  MANDATORY_SECTIONS = {
    composition_sections: [
      {
        code: CompositionSectionsConstants::PROBLEMS_SECTION[:code],
        short: CompositionSectionsConstants::PROBLEMS_SECTION[:title],
        entries: [
          { profiles: ['Condition|http://hl7.org/fhir/StructureDefinition/Condition',
                       'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
          { profiles: ['Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition'] }
        ]
      },
      {
        code: CompositionSectionsConstants::ALLERGIES_SECTION[:code],
        short: CompositionSectionsConstants::ALLERGIES_SECTION[:title],
        entries: [
          { profiles: ['AllergyIntolerance|http://hl7.org/fhir/StructureDefinition/AllergyIntolerance',
                       'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
          { profiles: ['AllergyIntolerance|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance'] }
        ]
      },
      {
        code: CompositionSectionsConstants::MEDICATION_SECTION[:code],
        short: CompositionSectionsConstants::MEDICATION_SECTION[:title],
        entries: [
          { profiles: ['MedicationStatement|http://hl7.org/fhir/StructureDefinition/MedicationStatement',
                       'MedicationRequest|http://hl7.org/fhir/StructureDefinition/MedicationRequest'] },
          { profiles: ['MedicationStatement|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement',
                       'MedicationRequest|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest'] }
        ]
      }
    ],
    groups: [
      {
        resource: 'Condition',
        must_supports: {
          elements: [
            { path: 'category' },
            { path: 'code' },
            { path: 'subject' },
            { path: 'subject.reference' }
          ]
        },
        mandatory_elements: %w[
          Condition.category
          Condition.code
          Condition.subject
          Condition.subject.reference
        ]
      },
      {
        resource: 'AllergyIntolerance',
        profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance',
        must_supports: {
          elements: [
            { path: 'patient' },
            { path: 'code' }
          ]
        },
        mandatory_elements: %w[
          AllergyIntolerance.patient
          AllergyIntolerance.code
        ]
      },
      {
        resource: 'MedicationStatement',
        profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement',
        must_supports: {
          elements: [
            { path: 'status' },
            { path: 'subject' },
            { path: 'medicationCodeableConcept' }
          ]
        },
        mandatory_elements: %w[
          MedicationStatement.status
          MedicationStatement.subject
          MedicationStatement.medicationCodeableConcept
        ]
      }
    ]
  }.freeze

  RECOMMENDED_SECTIONS = {
    composition_sections: [
      {
        code: CompositionSectionsConstants::IMMUNIZATIONS_SECTION[:code],
        short: CompositionSectionsConstants::IMMUNIZATIONS_SECTION[:title],
        entries: [
          { profiles: ['Immunization|http://hl7.org/fhir/StructureDefinition/Immunization',
                       'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
          { profiles: ['Immunization|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization'] }
        ]
      },
      {
        code: CompositionSectionsConstants::RESULTS_SECTION[:code],
        short: CompositionSectionsConstants::RESULTS_SECTION[:title],
        entries: [
          { profiles: ['Observation|http://hl7.org/fhir/StructureDefinition/Observation',
                       'DiagnosticReport|http://hl7.org/fhir/StructureDefinition/DiagnosticReport',
                       'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
          { profiles: ['Observation|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path'] }
        ]
      }
    ]
  }.freeze

  OPTIONAL_SECTIONS = {
    composition_sections: [
      {
        code: CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code],
        short: CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:title],
        entries: [
          { profiles: ['Consent|http://hl7.org/fhir/StructureDefinition/Consent',
                       'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] }
        ]
      }
    ]
  }.freeze
end
