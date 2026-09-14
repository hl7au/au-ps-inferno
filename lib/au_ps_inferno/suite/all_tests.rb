# frozen_string_literal: true

require_relative 'bundle_acquisition/bundle_acquisition'

require_relative 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'

require_relative 'au_ps_bundle_instance/bundle_validation'
require_relative 'au_ps_bundle_instance/au_ps_bundle_must_support_conformance'
require_relative 'au_ps_bundle_instance/au_ps_composition_must_support_conformance'
require_relative 'au_ps_bundle_instance/au_ps_composition_mandatory_sections'
require_relative 'au_ps_bundle_instance/au_ps_composition_recommended_sections'
require_relative 'au_ps_bundle_instance/au_ps_composition_optional_sections'
require_relative 'au_ps_bundle_instance/au_ps_composition_undefined_sections'
require_relative 'au_ps_bundle_instance/au_ps_composition_subject'
require_relative 'au_ps_bundle_instance/au_ps_composition_author'
require_relative 'au_ps_bundle_instance/au_ps_composition_custodian'
require_relative 'au_ps_bundle_instance/au_ps_composition_attester'

module AUPSTestKit
  # Wraps every group in the suite so the UI's left-hand navigation shows a single
  # top-level entry, with all the underlying groups nested beneath it.
  class AUPSSuiteAllTests < Inferno::TestGroup
    title 'AU PS Tests'
    description 'Validates AU PS (Australian Primary Care and Shared Health) bundles, ' \
                'compositions, sections, and server CapabilityStatement support.'
    id :suite_all_tests

    group from: :suite_bundle_acquisition
    group from: :au_ps_retrieve_cs_group_100preview
    group from: :suite_au_ps_bundle_instance_bundle_validation
    group from: :suite_au_ps_bundle_instance_au_ps_bundle_must_support_conformance
    group from: :suite_au_ps_bundle_instance_au_ps_composition_must_support_conformance
    group from: :suite_au_ps_bundle_instance_au_ps_composition_mandatory_sections
    group from: :suite_au_ps_bundle_instance_au_ps_composition_recommended_sections
    group from: :suite_au_ps_bundle_instance_au_ps_composition_optional_sections
    group from: :suite_au_ps_bundle_instance_au_ps_composition_undefined_sections
    group from: :suite_au_ps_bundle_instance_au_ps_composition_subject
    group from: :suite_au_ps_bundle_instance_au_ps_composition_author
    group from: :suite_au_ps_bundle_instance_au_ps_composition_custodian
    group from: :suite_au_ps_bundle_instance_au_ps_composition_attester
  end
end
