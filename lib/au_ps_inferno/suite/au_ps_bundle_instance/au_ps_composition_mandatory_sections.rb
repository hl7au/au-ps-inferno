# frozen_string_literal: true

require_relative 'au_ps_composition_mandatory_sections/bundle_static_composition_mandatory_sections_sections_shall_populated'

require_relative 'au_ps_composition_mandatory_sections/bundle_static_composition_mandatory_sections_mandatory_sections_entry_profiles'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Mandatory Sections
  class BundleStaticCompositionMandatorySections < Inferno::TestGroup
    title 'AU PS Composition Mandatory Sections'
    description 'Verify the mandatory sections are correctly populated in the AU PS Composition resource'
    id :bundle_static_composition_mandatory_sections

    run_as_group

    test from: :bundle_static_composition_mandatory_sections_sections_shall_populated

    test from: :bundle_static_composition_mandatory_sections_mandatory_sections_entry_profiles
  end
end
