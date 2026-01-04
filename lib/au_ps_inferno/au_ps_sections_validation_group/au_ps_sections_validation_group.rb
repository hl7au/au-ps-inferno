# frozen_string_literal: true

require_relative './au_ps_sections_problems_validation'
require_relative './au_ps_sections_allergies_validation'
require_relative './au_ps_sections_medications_validation'
require_relative './au_ps_sections_immunizations_validation'
require_relative './au_ps_sections_results_validation'
require_relative './au_ps_sections_procedures_validation'
require_relative './au_ps_sections_medical_devices_validation'
require_relative '../utils/constants'

module AUPSTestKit
  # Verify that the AU PS Sections are valid
  class AUPSSectionsValidationGroup < Inferno::TestGroup
    extend Constants

    title 'AU PS Sections Validation'
    description 'Verify that an AU PS Sections are valid.'
    id :au_ps_sections_validation_group
    run_as_group

    test from: :au_ps_sections_problems_validation
    test from: :au_ps_sections_allergies_validation
    test from: :au_ps_sections_medications_validation
    test from: :au_ps_sections_immunizations_validation
    test from: :au_ps_sections_results_validation
    test from: :au_ps_sections_procedures_validation
    test from: :au_ps_sections_medical_devices_validation
  end
end
