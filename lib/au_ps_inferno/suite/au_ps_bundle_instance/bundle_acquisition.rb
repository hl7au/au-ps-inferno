# frozen_string_literal: true

require_relative 'suite_au_ps_bundle_instance_bundle_provide'
require_relative 'suite_au_ps_bundle_instance_bundle_retrieve'
require_relative 'suite_au_ps_bundle_instance_bundle_summary'

module AUPSTestKit
  # Acquires the AU PS Bundle via whichever retrieval method was selected
  class AUPSSuiteAuPsBundleInstanceBundleAcquisition < Inferno::TestGroup
    title 'Acquire AU PS Bundle'
    description 'Acquires the Bundle to validate — by pasted text, FHIR server retrieval, or the ' \
                '$summary operation, according to the selected bundle retrieval method — and stores ' \
                'it for the validation tests in this group.'
    id :suite_au_ps_bundle_instance_bundle_acquisition

    run_as_group

    test from: :suite_au_ps_bundle_instance_bundle_provide
    test from: :suite_au_ps_bundle_instance_bundle_retrieve
    test from: :suite_au_ps_bundle_instance_bundle_summary
  end
end
