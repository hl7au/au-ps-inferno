# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-elements SHALL be populated if a value is known
  class AUPSSuiteAuPsBundleInstanceAuPsCompositionAuthorMustSupportSubelementsShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support sub-elements SHALL be populated if a value is known'
    description 'Must Support sub-elements SHALL be populated if a value is known'
    id :suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_subelements

    run do
      ms_sub_elements_populated_message('author')
    end
  end
end
