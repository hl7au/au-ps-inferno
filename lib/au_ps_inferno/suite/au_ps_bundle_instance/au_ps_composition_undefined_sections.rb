# frozen_string_literal: true

require_relative 'au_ps_composition_undefined_sections/bundle_static_composition_undefined_sections_sections_may_undefined'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Undefined Sections
  class BundleStaticCompositionUndefinedSections < Inferno::TestGroup
    title 'AU PS Composition Undefined Sections'
    description 'Verify the undefined sections are correctly populated in the AU PS Composition resource.'
    id :bundle_static_composition_undefined_sections

    optional

    run_as_group

    test from: :bundle_static_composition_undefined_sections_sections_may_undefined
  end
end
