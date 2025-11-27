module Constants
  MANDATORY_SECTIONS = %w[11450-4 48765-2 10160-0].freeze
  RECOMMENDED_SECTIONS = %w[11369-6 30954-2 47519-4 46264-8].freeze
  OPTIONAL_SECTIONS = %w[42348-3 104605-1 47420-5 11348-0 10162-6 81338-6 18776-5 29762-2 8716-3].freeze
  ALL_SECTIONS = (MANDATORY_SECTIONS + RECOMMENDED_SECTIONS + OPTIONAL_SECTIONS).freeze

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
    }
  }
end
