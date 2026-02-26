# frozen_string_literal: true

require_relative '../../utils/bundle_is_valid_class'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class AUPSBundleIsValidTest050preview < BundleIsValidClass
    id :au_ps_bundle_is_valid_test_050preview
    title 'AU PS Bundle is valid'
    description 'Validates that a Bundle resource conforms to the AU PS Bundle profile ' \
      '(http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle). The test accepts a pre-existing '\
      'Bundle resource to validate directly.'
  end
end
