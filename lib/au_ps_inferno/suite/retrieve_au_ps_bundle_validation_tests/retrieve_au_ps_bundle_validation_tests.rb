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
  # Automatically generated high order group for Retrieve AU PS Bundle validation tests
  class BundleRetrieval < Inferno::TestGroup
    title 'Retrieve AU PS Bundle validation tests'
    description 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle'
    id :bundle_retrieval

    run_as_group

    group from: :bundle_retrieval_bundle_validation

    group from: :bundle_retrieval_bundle_must_support_conformance

    group from: :bundle_retrieval_composition_must_support_conformance

    group from: :bundle_retrieval_composition_mandatory_sections

    group from: :bundle_retrieval_composition_recommended_sections

    group from: :bundle_retrieval_composition_optional_sections

    group from: :bundle_retrieval_composition_undefined_sections

    group from: :bundle_retrieval_composition_subject

    group from: :bundle_retrieval_composition_author

    group from: :bundle_retrieval_composition_custodian

    group from: :bundle_retrieval_composition_attester
  end
end
