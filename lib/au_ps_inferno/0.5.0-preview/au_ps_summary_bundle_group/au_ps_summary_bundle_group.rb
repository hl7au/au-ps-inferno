# frozen_string_literal: true

require_relative '../../utils/constants'
require_relative './au_ps_summary_valid_bundle'
require_relative './au_ps_summary_bundle_has_must_support_elements'
require_relative './au_ps_summary_bundle_composition_must_support_elements'
require_relative './au_ps_summary_bundle_composition_mandatory_sections'
require_relative './au_ps_summary_bundle_composition_recommended_sections'
require_relative './au_ps_summary_bundle_composition_optional_sections'
require_relative './au_ps_summary_bundle_composition_other_sections'

module AUPSTestKit
  # Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle
  class AUPSSummaryBundleGroup050preview < Inferno::TestGroup
    extend Constants

    title 'Generate AU PS using IPS $summary validation tests'
    description 'Generate AU Patient Summary using IPS $summary operation and verify response is valid ' \
      'AU PS Bundle'
    id :au_ps_summary_bundle_group_050preview

    fhir_client do
      url :url
      oauth_credentials :credentials
      headers(header_name.present? && header_value.present? ? { header_name => header_value } : {})
    end

    run_as_group

    test from: :au_ps_summary_valid_bundle_050preview
    test from: :au_ps_summary_bundle_has_must_support_elements_050preview
    test from: :au_ps_summary_bundle_composition_must_support_elements_050preview
    test from: :au_ps_summary_bundle_composition_mandatory_sections_050preview
    test from: :au_ps_summary_bundle_composition_recommended_sections_050preview
    test from: :au_ps_summary_bundle_composition_optional_sections_050preview
    test from: :au_ps_summary_bundle_composition_other_sections_050preview
  end
end
