# frozen_string_literal: true

require_relative 'bundle_decorator'
require_relative 'composition_utils/boolean_and_stats'

# Utilities for FHIR Composition resources
module CompositionUtils
  include CompositionUtilsBooleanAndStats

  def scratch_bundle
    scratch[:bundle_ips_resource]
  end

  def check_bundle_exists_in_scratch
    skip_if scratch_bundle.blank?, 'No Bundle resource provided'
  end

  def group_section_output(section_info_array)
    section_entities = {}
    section_info_array.each do |section_info|
      if section_entities.key?(section_info)
        section_entities[section_info] += 1
      else
        section_entities[section_info] = 1
      end
    end
    section_entities.map { |section_entity, count| "#{section_entity} x#{count}" }
  end
end
