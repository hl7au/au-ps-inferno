# frozen_string_literal: true

require_relative 'au_ps_composition_recommended_sections/suite_au_ps_bundle_instance_au_ps_composition_recommended_sections_sections_should_populated'

require_relative 'au_ps_composition_recommended_sections/composition_recommended_sections_recommended_sections_entry_profiles'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Recommended Sections
  class AUPSSuiteAuPsBundleInstanceAuPsCompositionRecommendedSections < Inferno::TestGroup
    title 'AU PS Composition Recommended Sections'
    description 'Verify the recommended sections are correctly populated in the Composition resource'
    id :suite_au_ps_bundle_instance_au_ps_composition_recommended_sections

    run_as_group

    test from: :suite_au_ps_bundle_instance_au_ps_composition_recommended_sections_sections_should_populated

    test from: :suite_au_ps_bundle_instance_au_ps_composition_recommended_sections_recommended_sections_entry_profiles
  end
end
