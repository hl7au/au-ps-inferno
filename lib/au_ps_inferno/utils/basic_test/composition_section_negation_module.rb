# frozen_string_literal: true

module AUPSTestKit
  # Warns when a section uses emptyReason=nilknown instead of an explicit negation entry.
  module BasicTestCompositionSectionNegationModule
    NILKNOWN_SYSTEM = 'http://terminology.hl7.org/CodeSystem/list-empty-reason'
    NILKNOWN_CODE = 'nilknown'

    NEGATION_EXAMPLE_BY_SECTION = {
      '11450-4' => 'Condition.code = 160245001 |No current problems or disability|',
      '48765-2' => 'AllergyIntolerance.code = 716186003 |No known allergy|',
      '10160-0' => 'MedicationStatement.medicationCodeableConcept = 787481004 |No known medications|'
    }.freeze

    private

    def warn_on_nilknown_empty_reason(section_codes_array)
      omit_unless_bundle_in_scratch

      composition = BundleDecorator.new(scratch_bundle).composition_resource
      section_codes_array.each { |code| warn_if_section_nilknown(composition, code) }

      assert true
    end

    def warn_if_section_nilknown(composition, section_code)
      section = composition.section_by_code(section_code)
      return if section.blank? || !nilknown_empty_reason?(section)

      add_message('warning', nilknown_warning_text(section_code))
    end

    def nilknown_empty_reason?(section)
      section.emptyReason&.coding&.any? do |coding|
        coding.system == NILKNOWN_SYSTEM && coding.code == NILKNOWN_CODE
      end
    end

    def nilknown_warning_text(section_code)
      example = NEGATION_EXAMPLE_BY_SECTION.fetch(section_code, 'an explicit negation code per profile guidance')
      "#{get_section_name(section_code)} uses emptyReason = nilknown ('Nil Known'). " \
        'AU PS prefers an explicit negation code on the section entry instead ' \
        "of Composition.section.emptyReason, e.g. #{example}."
    end
  end
end
