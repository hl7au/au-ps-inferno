module Constants
  MANDATORY_MS_ELEMENTS = [
    {:expression => "$.status", :label => "status"},
    {:expression => "$.type", :label => "type"},
    {:expression => "$.subject.reference", :label => "subject.reference"},
    {:expression => "$.date", :label => "date"},
    {:expression => "$.author[0]", :label => "author"},
    {:expression => "$.title", :label => "title"}
  ].freeze
  OPTIONAL_MS_ELEMENTS = [
    {:expression => "$.text", :label => "text"},
    {:expression => "$.identifier", :label => "identifier"},
    {:expression => "$.attester", :label => "asserter"},
    {:expression => "$.attester.mode", :label => "asserter.mode"},
    {:expression => "$.attester.time", :label => "asserter.time"},
    {:expression => "$.attester.party", :label => "asserter.party"},
    {:expression => "$.custodian", :label => "custodian"},
    {:expression => "$.event.code.coding.code", :label => "event"},
    {:expression => "$.event.code", :label => "event.code"},
    {:expression => "$.event.period", :label => "event.period"}].freeze

  MANDATORY_SECTIONS = %w[11450-4 48765-2 10160-0].freeze
  RECOMMENDED_SECTIONS = %w[11369-6 30954-2 47519-4 46264-8].freeze
  OPTIONAL_SECTIONS = %w[42348-3 104605-1 47420-5 11348-0 10162-6 81338-6 18776-5 29762-2 8716-3].freeze
  ALL_SECTIONS = (MANDATORY_SECTIONS + RECOMMENDED_SECTIONS + OPTIONAL_SECTIONS).freeze

  AU_PS_PROFILES_MAPPING_REQUIRED = {
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle" => "AU PS Bundle",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition" => "AU PS Composition",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient" => "AU PS Patient",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition" => "AU PS Condition",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance" => "AU PS AllergyIntolerance",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement" => "AU PS MedicationStatement",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest" => "AU PS MedicationRequest"
  }
  AU_PS_PROFILES_MAPPING_OTHER = {
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter" => "AU PS Encounter",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization" => "AU PS Immunization",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication" => "AU PS Medication",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path" => "AU PS Pathology Result Observation",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-smokingstatus" => "AU PS Smoking Status",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization" => "AU PS Organization",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner" => "AU PS Practitioner",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole" => "AU PS PractitionerRole",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure" => "AU PS Procedure",
    "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson" => "AU PS RelatedPerson",
  }

  TEXTS = {
    :au_ps_validation_group => {
      :title => 'AU PS Bundle Validation',
      :description => 'Verify that an AU PS Bundle is valid and contains required must support elements.'
    },
    :au_ps_bundle_is_valid_test => {
      :title => 'AU PS Bundle is valid',
      :description => 'Validates that a Bundle resource conforms to the AU PS Bundle profile (http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle). The test accepts either a patient_id to request Patient/{patient_id}/$summary, an identifier to request Patient/$summary?identifier={identifier}, or a pre-existing Bundle resource to validate directly.'
    },
    :au_ps_bundle_has_must_support_elements => {
      :title => 'Bundle has mandatory must-support elements',
      :description => 'Checks that the Bundle resource contains mandatory must-support elements (identifier, type, timestamp) and that all entries have a fullUrl. Also provides information about the resource types included in the Bundle.'
    },
    :au_ps_composition_must_support_elements => {
      :title => 'Composition has must-support elements',
      :description => 'Checks that the Composition resource contains mandatory must-support elements (status, type, subject.reference, date, author, title, section.title, section.text) and provides information about optional must-support elements (text, identifier, attester, custodian, event).'
    },
    :au_ps_composition_mandatory_sections => {
      :title => 'Composition contains mandatory sections with entry references',
      :description => 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.'
    },
    :au_ps_composition_recommended_sections => {
      :title => 'Composition contains recommended sections with entry references',
      :description => 'Displays information about recommended sections'
    },
    :au_ps_composition_optional_sections => {
      :title => 'Composition contains optional sections with entry references',
      :description => 'Displays information about optional sections'
    },
    :au_ps_composition_other_sections => {
      :title => 'Composition contains other sections with entry references',
      :description => 'Displays information about other sections'
    },
    :au_ps_retrieve_cs_group => {
      :title => 'Retrieve Capability Statement Tests',
      :description => 'Verify server provides valid Capability Statement and reports supported AU PS profiles and IPS recommended operations'
    },
    :au_ps_cs_is_valid => {
      :title => 'CapabilityStatement is valid',
      :description => 'Verify CapabilityStatement resource is valid'
    },
    :au_ps_cs_supports_ips_recommended_ops => {
      :title => 'CapabilityStatement supports IPS Recommended Operations',
      :description => 'IPS recommended operations referenced as supported in CapabilityStatement'
    },
    :au_ps_cs_supports_au_ps_profiles => {
      :title => 'CapabilityStatement supports AU PS Profiles',
      :description => 'AU PS Profiles referenced as supported in CapabilityStatement'
    },
    :au_ps_retrieve_bundle_group => {
      :title => 'Retrieve AU PS Bundle validation tests',
      :description => 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle'
    },
    :au_ps_retrieve_valid_bundle => {
      :title => 'Server provides valid requested AU PS Bundle',
      :description => 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle'
    },
    :au_ps_retrieve_bundle_has_must_support_elements => {
      :title => 'Bundle has mandatory must-support elements',
      :description => 'Checks that the Bundle resource contains mandatory must-support elements (identifier, type, timestamp) and that all entries have a fullUrl. Also provides information about the resource types included in the Bundle.'
    },
    :au_ps_retrieve_bundle_composition_must_support_elements => {
      :title => 'Composition has must-support elements',
      :description => 'Checks that the Composition resource contains mandatory must-support elements (status, type, subject.reference, date, author, title, section.title, section.text) and provides information about optional must-support elements (text, identifier, attester, custodian, event).'
    },
    :au_ps_retrieve_bundle_composition_mandatory_sections => {
      :title => 'Composition contains mandatory sections with entry references',
      :description => 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.'
    },
    :au_ps_retrieve_bundle_composition_recommended_sections => {
      :title => 'Composition contains recommended sections with entry references',
      :description => 'Displays information about recommended sections'
    },
    :au_ps_retrieve_bundle_composition_optional_sections => {
      :title => 'Composition contains optional sections with entry references',
      :description => 'Displays information about optional sections'
    },
    :au_ps_retrieve_bundle_composition_other_sections => {
      :title => 'Composition contains other sections with entry references',
      :description => 'Displays information about other sections'
    },
    :au_ps_summary_bundle_group => {
      :title => 'Generate AU PS using IPS $summary validation tests',
      :description => 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle'
    },
    :au_ps_summary_valid_bundle => {
      :title => 'Server generates AU Patient Summary using IPS $summary operation',
      :description => 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle'
    },
    :au_ps_summary_bundle_has_must_support_elements => {
      :title => 'Bundle has mandatory must-support elements',
      :description => 'Checks that the Bundle resource contains mandatory must-support elements (identifier, type, timestamp) and that all entries have a fullUrl. Also provides information about the resource types included in the Bundle.'
    },
    :au_ps_summary_bundle_composition_must_support_elements => {
      :title => 'Composition has must-support elements',
      :description => 'Checks that the Composition resource contains mandatory must-support elements (status, type, subject.reference, date, author, title, section.title, section.text) and provides information about optional must-support elements (text, identifier, attester, custodian, event).'
    },
    :au_ps_summary_bundle_composition_mandatory_sections => {
      :title => 'Composition contains mandatory sections with entry references',
      :description => 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.'
    },
    :au_ps_summary_bundle_composition_recommended_sections => {
      :title => 'Composition contains recommended sections with entry references',
      :description => 'Displays information about recommended sections'
    },
    :au_ps_summary_bundle_composition_optional_sections => {
      :title => 'Composition contains optional sections with entry references',
      :description => 'Displays information about optional sections'
    },
    :au_ps_summary_bundle_composition_other_sections => {
      :title => 'Composition contains other sections with entry references',
      :description => 'Displays information about other sections'
    },
  }
end
