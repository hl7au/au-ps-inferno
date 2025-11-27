# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  class AUPSCompositionOptionalSection < BasicTest
    title 'Composition contains optional sections with entry references'
    description 'Displays information about optional sections'
    id :au_ps_composition_optional_sections

    run do
      get_composition_sections_info(OPTIONAL_SECTIONS)
    end
  end
end
