# frozen_string_literal: true

require_relative 'au_ps_composition_custodian/suite_au_ps_bundle_instance_au_ps_composition_custodian_custodian_ms_elements'

require_relative 'au_ps_composition_custodian/suite_au_ps_bundle_instance_au_ps_composition_custodian_custodian_ms_subelements'

require_relative 'au_ps_composition_custodian/suite_au_ps_bundle_instance_au_ps_composition_custodian_custodian_ms_identifier_slices'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Custodian
  class AUPSSuiteAuPsBundleInstanceAuPsCompositionCustodian100preview < Inferno::TestGroup
    title 'AU PS Composition Custodian'
    description 'Verify the referenced custodian is a correctly populated AU PS Organization resource.'
    id :suite_au_ps_bundle_instance_au_ps_composition_custodian_100preview

    optional

    run_as_group

    test from: :suite_au_ps_bundle_instance_au_ps_composition_custodian_custodian_ms_elements_100preview

    test from: :suite_au_ps_bundle_instance_au_ps_composition_custodian_custodian_ms_subelements_100preview

    test from: :suite_au_ps_bundle_instance_au_ps_composition_custodian_custodian_ms_identifier_slices_100preview
  end
end
