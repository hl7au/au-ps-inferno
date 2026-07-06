# frozen_string_literal: true

require_relative 'au_ps_composition_optional_sections/bundle_retrieval_composition_optional_sections_sections_may_populated'

require_relative 'au_ps_composition_optional_sections/bundle_retrieval_composition_optional_sections_optional_sections_entry_profiles'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Optional Sections
  class BundleRetrievalCompositionOptionalSections < Inferno::TestGroup
    title 'AU PS Composition Optional Sections'
    description 'Verify the optional sections are correctly populated in the AU PS Composition resource'
    id :bundle_retrieval_composition_optional_sections

    run_as_group

    test from: :bundle_retrieval_composition_optional_sections_sections_may_populated

    test from: :bundle_retrieval_composition_optional_sections_optional_sections_entry_profiles
  end
end
