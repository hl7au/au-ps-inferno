# frozen_string_literal: true

require_relative 'au_ps_composition_optional_sections/ips_summary_composition_optional_sections_sections_may_populated'

require_relative 'au_ps_composition_optional_sections/ips_summary_composition_optional_sections_optional_sections_entry_profiles'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Optional Sections
  class IpsSummaryCompositionOptionalSections < Inferno::TestGroup
    title 'AU PS Composition Optional Sections'
    description 'Verify the optional sections are correctly populated in the AU PS Composition resource'
    id :ips_summary_composition_optional_sections

    run_as_group

    test from: :ips_summary_composition_optional_sections_sections_may_populated

    test from: :ips_summary_composition_optional_sections_optional_sections_entry_profiles
  end
end
