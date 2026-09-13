# frozen_string_literal: true

require_relative 'bundle_decorator'
require_relative 'composition_utils/boolean_and_stats'

# Utilities for FHIR Composition resources
module CompositionUtils
  include CompositionUtilsBooleanAndStats

  NO_BUNDLE_OMIT_MESSAGE = 'No AU PS Bundle was loaded by this test group (its inputs were not provided or ' \
                           'the Bundle could not be acquired), so this test is omitted.'

  # There is a single Bundle-acquisition path in the suite, so all groups share one scratch key.
  BUNDLE_SCRATCH_KEY = :bundle_ips_resource

  def scratch_bundle
    scratch[BUNDLE_SCRATCH_KEY]
  end

  def save_bundle_to_scratch(bundle)
    scratch[BUNDLE_SCRATCH_KEY] = bundle
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
