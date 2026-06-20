# frozen_string_literal: true



require_relative 'au_ps_bundle_conformance_tests/suite_100preview_au_ps_bundle_instance_au_ps_bundle_conformance_tests_bundle_must_support_populated'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Bundle Conformance Tests
  class AUPSSuite100previewAuPsBundleInstanceAuPsBundleConformanceTests < Inferno::TestGroup
    title 'AU PS Bundle Conformance Tests'
    description 'Verifies the Bundle resource is populated according to AU PS Bundle conformance requirements.'
    id :suite_100preview_au_ps_bundle_instance_au_ps_bundle_conformance_tests
    
    
    run_as_group
    

    
    test from: :suite_100preview_au_ps_bundle_instance_au_ps_bundle_conformance_tests_bundle_must_support_populated
    
  end
end
