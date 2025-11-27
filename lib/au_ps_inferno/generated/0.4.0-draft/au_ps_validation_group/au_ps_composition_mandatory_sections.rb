# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/composition_decorator'
require_relative '../../../utils/bundle_decorator'
require_relative '../../../utils/basic_test_class'

SECTIONS = %w[11450-4 48765-2 10160-0].freeze

module AUPSTestKit
  class AUPSCompositionMandatorySection < BasicTest
    title 'Composition contains mandatory sections with entry references'
    description 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.'
    id :au_ps_composition_mandatory_sections

    def composition_mandatory_sections_info
      get_composition_sections_info(SECTIONS)
    end

    run do
      composition_mandatory_sections_info
    end
  end
end
