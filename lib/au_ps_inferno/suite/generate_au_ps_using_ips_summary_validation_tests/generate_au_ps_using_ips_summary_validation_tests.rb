# frozen_string_literal: true

require_relative 'bundle_validation'

require_relative 'au_ps_bundle_must_support_conformance'

require_relative 'au_ps_composition_must_support_conformance'

require_relative 'au_ps_composition_mandatory_sections'

require_relative 'au_ps_composition_recommended_sections'

require_relative 'au_ps_composition_optional_sections'

require_relative 'au_ps_composition_undefined_sections'

require_relative 'au_ps_composition_subject'

require_relative 'au_ps_composition_author'

require_relative 'au_ps_composition_custodian'

require_relative 'au_ps_composition_attester'

module AUPSTestKit
  # Automatically generated high order group for Generate AU PS using IPS $summary validation tests
  class IpsSummary < Inferno::TestGroup
    title 'Generate AU PS using IPS $summary validation tests'
    description 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle'
    id :ips_summary

    run_as_group

    group from: :ips_summary_bundle_validation

    group from: :ips_summary_bundle_must_support_conformance

    group from: :ips_summary_composition_must_support_conformance

    group from: :ips_summary_composition_mandatory_sections

    group from: :ips_summary_composition_recommended_sections

    group from: :ips_summary_composition_optional_sections

    group from: :ips_summary_composition_undefined_sections

    group from: :ips_summary_composition_subject

    group from: :ips_summary_composition_author

    group from: :ips_summary_composition_custodian

    group from: :ips_summary_composition_attester
  end
end
