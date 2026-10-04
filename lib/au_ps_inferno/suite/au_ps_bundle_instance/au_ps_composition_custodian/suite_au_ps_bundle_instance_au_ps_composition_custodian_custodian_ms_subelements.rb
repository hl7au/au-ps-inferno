# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-element SHALL be populated if a value is known
  class AUPSSuiteAuPsBundleInstanceAuPsCompositionCustodianMustSupportSubelementShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support sub-element SHALL be populated if a value is known'
    description 'Must Support sub-element SHALL be populated if a value is known'
    id :suite_au_ps_bundle_instance_au_ps_composition_custodian_custodian_ms_subelements

    run do
      ms_sub_elements_populated_message('custodian')
    end
  end
end
