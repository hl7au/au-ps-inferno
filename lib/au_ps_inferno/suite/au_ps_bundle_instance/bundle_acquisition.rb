# frozen_string_literal: true

require_relative 'suite_au_ps_bundle_instance_bundle_provide'

module AUPSTestKit
  # Automatically generated primitive group for Provide AU PS Bundle
  class AUPSSuiteAuPsBundleInstanceBundleAcquisition < Inferno::TestGroup
    title 'Provide AU PS Bundle'
    description 'Loads the Bundle resource pasted as text and stores it for the validation tests in this group.'
    id :suite_au_ps_bundle_instance_bundle_acquisition

    run_as_group

    test from: :suite_au_ps_bundle_instance_bundle_provide
  end
end
