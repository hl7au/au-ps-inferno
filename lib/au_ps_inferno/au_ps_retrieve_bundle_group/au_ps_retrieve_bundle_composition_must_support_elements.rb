# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  class AUPSRetrieveBundleCompositionMUSTSUPPORTElements < BasicTest
    title t_title(:au_ps_retrieve_bundle_composition_must_support_elements)
    description t_description(:au_ps_retrieve_bundle_composition_must_support_elements)
    id :au_ps_retrieve_bundle_composition_must_support_elements

    run do
      composition_mandatory_ms_elements_info
    end
  end
end
