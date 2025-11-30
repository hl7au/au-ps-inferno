# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The Must Support elements populated in the Composition resource.
  class AUPSCompositionMUSTSUPPORTElements < BasicTest
    title 'Composition has must-support elements'
    description 'Checks that the Composition resource contains mandatory must-support elements ' \
      '(status, type, subject.reference, date, author, title, section.title, section.text) and provides ' \
      'information about optional must-support elements (text, identifier, attester, custodian, event).'
    id :au_ps_composition_must_support_elements

    run do
      composition_mandatory_ms_elements_info
    end
  end
end
