# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  class AUPSCompositionMandatorySection < BasicTest
    title t_title(:au_ps_composition_mandatory_sections)
    description t_description(:au_ps_composition_mandatory_sections)
    id :au_ps_composition_mandatory_sections

    run do
      get_composition_sections_info(Constants::MANDATORY_SECTIONS)
    end
  end
end
