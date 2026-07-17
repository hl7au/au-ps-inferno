# frozen_string_literal: true

require_relative 'bundle_decorator'
require_relative 'composition_utils/boolean_and_stats'

# Utilities for FHIR Composition resources
module CompositionUtils
  include CompositionUtilsBooleanAndStats

  NO_BUNDLE_OMIT_MESSAGE = 'No AU PS Bundle was loaded by this test group (its inputs were not provided or ' \
                           'the Bundle could not be acquired), so this test is omitted.'

  # Each top-level group keeps its Bundle under its own scratch key so that a
  # group can never validate a Bundle acquired by a different group.
  BUNDLE_SOURCE_GROUPS = {
    'retrieve_au_ps_bundle_validation_tests' => 'retrieve',
    'generate_au_ps_using_ips_summary_validation_tests' => 'summary',
    'au_ps_bundle_instance' => 'instance'
  }.freeze

  def bundle_scratch_key
    id_str = self.class.id.to_s
    _slug, source = BUNDLE_SOURCE_GROUPS.find { |slug, _| id_str.include?(slug) }
    source ? :"bundle_ips_resource_#{source}" : :bundle_ips_resource
  end

  def scratch_bundle
    scratch[bundle_scratch_key]
  end

  def save_bundle_to_scratch(bundle)
    scratch[bundle_scratch_key] = bundle
  end

  def omit_unless_bundle_in_scratch
    omit_if scratch_bundle.blank?, NO_BUNDLE_OMIT_MESSAGE
  end

  def group_section_output(section_info_array)
    section_entities = {}
    section_info_array.each do |section_info|
      if section_entities.keys.include?(section_info)
        section_entities[section_info] += 1
      else
        section_entities[section_info] = 1
      end
    end
    section_entities.keys.map { |section_entity| "#{section_entity} x#{section_entities[section_entity]}" }
  end
end
