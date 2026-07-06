# frozen_string_literal: true

require_relative 'au_ps_composition_undefined_sections/ips_summary_composition_undefined_sections_sections_may_undefined'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Undefined Sections
  class IpsSummaryCompositionUndefinedSections < Inferno::TestGroup
    title 'AU PS Composition Undefined Sections'
    description 'Verify the undefined sections are correctly populated in the AU PS Composition resource.'
    id :ips_summary_composition_undefined_sections

    optional

    run_as_group

    test from: :ips_summary_composition_undefined_sections_sections_may_undefined
  end
end
