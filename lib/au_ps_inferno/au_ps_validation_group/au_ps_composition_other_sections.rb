# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  class AUPSCompositionOtherSection < BasicTest
    title TEXTS[:au_ps_composition_other_sections][:title]
    description TEXTS[:au_ps_composition_other_sections][:description]
    id :au_ps_composition_other_sections

    run do
      check_other_sections
    end
  end
end
