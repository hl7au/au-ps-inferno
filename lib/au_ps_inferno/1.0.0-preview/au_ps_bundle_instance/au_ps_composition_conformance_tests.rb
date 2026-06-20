# frozen_string_literal: true



require_relative 'au_ps_composition_conformance_tests/suite_100preview_au_ps_bundle_instance_au_ps_composition_conformance_tests_composition_must_support_populated'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Conformance Tests
  class AUPSSuite100previewAuPsBundleInstanceAuPsCompositionConformanceTests < Inferno::TestGroup
    title 'AU PS Composition Conformance Tests'
    description 'Verifies the Composition resource is populated according to AU PS Composition conformance requirements.'
    id :suite_100preview_au_ps_bundle_instance_au_ps_composition_conformance_tests
    
    
    run_as_group
    

    
    test from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_conformance_tests_composition_must_support_populated
    
  end
end
