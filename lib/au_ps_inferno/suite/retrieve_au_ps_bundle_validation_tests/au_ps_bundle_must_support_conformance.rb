# frozen_string_literal: true

require_relative 'au_ps_bundle_must_support_conformance/bundle_retrieval_bundle_must_support_conformance_bundle_must_support_populated'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Bundle Must Support Conformance
  class BundleRetrievalBundleMustSupportConformance < Inferno::TestGroup
    title 'AU PS Bundle Must Support Conformance'
    description 'Verifies that Must Support elements at the bundle level are populated when data is available.'
    id :bundle_retrieval_bundle_must_support_conformance

    run_as_group

    test from: :bundle_retrieval_bundle_must_support_conformance_bundle_must_support_populated
  end
end
