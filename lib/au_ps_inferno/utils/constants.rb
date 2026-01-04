# frozen_string_literal: true

# Common constants used in tests
module Constants
  MANDATORY_MS_ELEMENTS = [
    { expression: 'status', label: 'status' },
    { expression: 'type', label: 'type' },
    { expression: 'subject.reference', label: 'subject.reference' },
    { expression: 'date', label: 'date' },
    { expression: 'author', label: 'author' },
    { expression: 'title', label: 'title' }
  ].freeze

  OPTIONAL_MS_ELEMENTS = [
    { expression: 'text', label: 'text' },
    { expression: 'identifier', label: 'identifier' },
    { expression: 'attester', label: 'attester' },
    { expression: 'attester.mode', label: 'attester.mode' },
    { expression: 'attester.time', label: 'attester.time' },
    { expression: 'attester.party', label: 'attester.party' },
    { expression: 'custodian', label: 'custodian' },
    { expression: 'event.code.coding.code', label: 'event' },
    { expression: 'event.code', label: 'event.code' },
    { expression: 'event.period', label: 'event.period' }
  ].freeze

  MANDATORY_SECTIONS = %w[11450-4 48765-2 10160-0].freeze
  RECOMMENDED_SECTIONS = %w[11369-6 30954-2 47519-4 46264-8].freeze
  OPTIONAL_SECTIONS = %w[42348-3 104605-1 47420-5 11348-0 10162-6 81338-6 18776-5 29762-2 8716-3].freeze
  ALL_SECTIONS = (MANDATORY_SECTIONS + RECOMMENDED_SECTIONS + OPTIONAL_SECTIONS).freeze
  SECTIONS_CODES_MAPPING = {
    '11450-4' => 'Problem list', '48765-2' => 'Allergies and adverse reactions Document',
    '10160-0' => 'History of Medication use Narrative', '11369-6' => 'History of Immunization note',
    '30954-2' => 'Relevant diagnostic tests/laboratory data note', '47519-4' => 'History of Procedures Document',
    '46264-8' => 'History of medical device use', '42348-3' => 'Advance healthcare directives',
    '104605-1' => 'Alert', '47420-5' => 'Functional status assessment note',
    '11348-0' => 'History of Past illness note', '10162-6' => 'History of pregnancies Narrative',
    '81338-6' => 'Patient Goals, preferences, and priorities for care experience',
    '18776-5' => 'Plan of care note', '29762-2' => 'Social history note', '8716-3' => 'Vital signs note'
  }.freeze

  SECTIONS_NAMES_MAPPING = {
    'PROBLEM_LIST' => {
      'code' => '11450-4',
      'display' => 'Problem list',
      'resources' => {
        'Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition' => {}
      }
    },
    'ALLERGIES_AND_ADVERSE_REACTIONS_DOCUMENT' => {
      'code' => '48765-2',
      'display' => 'Allergies and adverse reactions Document',
      'resources' => {
        'AllergyIntolerance|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance' => {}
      }
    },
    'HISTORY_OF_MEDICATION_USE_NARRATIVE' => {
      'code' => '10160-0',
      'display' => 'History of Medication use Narrative',
      'resources' => {
        'MedicationStatement|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement' => {},
        'MedicationRequest|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest' => {}
      }
    },
    'HISTORY_OF_IMMUNIZATION_NOTE' => {
      'code' => '11369-6',
      'display' => 'History of Immunization note',
      'resources' => {
        'Immunization|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization' => {}
      }
    },
    'RELEVANT_DIAGNOSTIC_TESTS_LABORATORY_DATA_NOTE' => {
      'code' => '30954-2',
      'display' => 'Relevant diagnostic tests/laboratory data note',
      'resources' => {
        'Observation|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path' => {
          'requirements' => [
            {
              'path' => 'category.coding.code',
              'value' => 'laboratory'
            }
          ]
        },
        'Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-results-radiology-uv-ips' => {
          'requirements' => [
            {
              'path' => 'category.coding.code',
              'value' => 'imaging'
            }
          ]
        },
        'DiagnosticReport|http://hl7.org/fhir/uv/ips/StructureDefinition/DiagnosticReport-uv-ips' => {}
      }
    },
    'HISTORY_OF_PROCEDURES_DOCUMENT' => {
      'code' => '47519-4',
      'display' => 'History of Procedures Document',
      'resources' => {
        'Procedure|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure' => {}
      }
    },
    'HISTORY_OF_MEDICAL_DEVICE_USE' => {
      'code' => '46264-8',
      'display' => 'History of medical device use',
      'resources' => {
        'DeviceUseStatement|http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips' => {}
      }
    },
    'ADVANCE_HEALTHCARE_DIRECTIVES' => {
      'code' => '42348-3',
      'display' => 'Advance healthcare directives',
      'resources' => {
        'Consent' => {}
      }
    },
    'ALERT' => {
      'code' => '104605-1',
      'display' => 'Alert',
      'resources' => {
        'Flag|http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips' => {}
      }
    },
    'FUNCTIONAL_STATUS_ASSESSMENT_NOTE' => {
      'code' => '47420-5',
      'display' => 'Functional status assessment note',
      'resources' => {
        'Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition' => {},
        'ClinicalImpression' => {}
      }
    },
    'HISTORY_OF_PAST_ILLNESS_NOTE' => {
      'code' => '11348-0',
      'display' => 'History of Past illness note',
      'resources' => {
        'Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition' => {}
      }
    },
    'HISTORY_OF_PREGNANCIES_NARRATIVE' => {
      'code' => '10162-6',
      'display' => 'History of pregnancies Narrative',
      'resources' => {
        'Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips' => {
          'requirements' => [
            {
              'path' => 'code.coding.code',
              'value' => '82810-3'
            }
          ]
        },
        'Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-outcome-uv-ips' => {
          'requirements' => [
            {
              'path' => 'code.coding.code',
              'value' => [
                '11636-8',
                '11637-6',
                '11638-4',
                '11639-2',
                '11640-0',
                '11612-9',
                '11613-7',
                '11614-5',
                '33065-4'
              ]
            }
          ]
        }
      }
    },
    'PATIENT_GOALS_PREFERENCES_AND_PRIORITIES_FOR_CARE_EXPERIENCE' => {
      'code' => '81338-6',
      'display' => 'Patient Goals, preferences, and priorities for care experience',
      'resources' => {}
    },
    'PLAN_OF_CARE_NOTE' => {
      'code' => '18776-5',
      'display' => 'Plan of care note',
      'resources' => {
        'CarePlan' => {},
        'ImmunizationRecommendation' => {},
      }
    },
    'SOCIAL_HISTORY_NOTE' => {
      'code' => '29762-2',
      'display' => 'Social history note',
      'resources' => {
        'Observation|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-smokingstatus' => {
          'requirements' => [
            {
              'path' => 'code.coding.code',
              'value' => '1747861000168109'
            }
          ]
        },
        'Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-alcoholuse-uv-ips' => {
          'requirements' => [
            {
              'path' => 'code.coding.code',
              'value' => '74013-4'
            }
          ]
        }
      }
    },
    'VITAL_SIGNS_NOTE' => {
      'code' => '8716-3',
      'display' => 'Vital signs note',
      'resources' => {
        'Observation|http://hl7.org/fhir/StructureDefinition/vitalsigns' => {}
      }
    }
  }.freeze

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
