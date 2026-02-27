# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # Verify the Must Support elements are correctly populated in the AU PS Bundle resource.
  class AUPSBundleHasMUSTSUPPORTElements100ballot < BasicTest
    title 'AU PS Bundle has Must Support elements  (Must Have)'
    description 'Verify the Must Support elements are correctly populated in the AU PS Bundle resource.'
    id :au_ps_bundle_has_must_support_elements_100ballot

    
    run do
      bundle_mandatory_ms_elements_info
    end
    
  end
end
