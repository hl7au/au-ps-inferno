# frozen_string_literal: true

require_relative 'au_ps_bundle_must_support_conformance/suite_au_ps_bundle_instance_au_ps_bundle_must_support_conformance_bundle_must_support_populated'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Bundle Must Support Conformance
  class AUPSSuiteAuPsBundleInstanceAuPsBundleMustSupportConformance100ballot < Inferno::TestGroup
    title 'AU PS Bundle Must Support Conformance'
    description 'Verifies that Must Support elements at the bundle level are populated when data is available.'
    id :suite_au_ps_bundle_instance_au_ps_bundle_must_support_conformance_100ballot

    run_as_group

    test from: :suite_au_ps_bundle_instance_au_ps_bundle_must_support_conformance_bundle_must_support_populated_100ballot
  end
end
