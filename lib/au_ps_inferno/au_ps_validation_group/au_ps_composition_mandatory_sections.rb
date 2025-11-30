# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The mandatory sections populated in the Composition resource.
  class AUPSCompositionMandatorySection < BasicTest
    title 'Composition contains mandatory sections with entry references'
    description 'Displays information about mandatory sections (Allergies and Intolerances, ' \
      'Medication Summary, Problem List) in the Composition resource, including the entry references within ' \
      'each section.'
    id :au_ps_composition_mandatory_sections

    run do
      read_composition_mandatory_sections_info
    end
  end
end
