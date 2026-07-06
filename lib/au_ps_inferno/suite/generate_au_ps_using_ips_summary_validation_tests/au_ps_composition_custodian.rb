# frozen_string_literal: true

require_relative 'au_ps_composition_custodian/ips_summary_composition_custodian_custodian_ms_elements'

require_relative 'au_ps_composition_custodian/ips_summary_composition_custodian_custodian_ms_subelements'

require_relative 'au_ps_composition_custodian/ips_summary_composition_custodian_custodian_ms_identifier_slices'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Custodian
  class IpsSummaryCompositionCustodian < Inferno::TestGroup
    title 'AU PS Composition Custodian'
    description 'Verify the referenced custodian is a correctly populated AU PS Organization resource.'
    id :ips_summary_composition_custodian

    optional

    run_as_group

    test from: :ips_summary_composition_custodian_custodian_ms_elements

    test from: :ips_summary_composition_custodian_custodian_ms_subelements

    test from: :ips_summary_composition_custodian_custodian_ms_identifier_slices
  end
end
