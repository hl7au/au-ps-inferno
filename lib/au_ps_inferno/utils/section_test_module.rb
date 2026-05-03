# frozen_string_literal: true

require_relative 'section_test_class'
require_relative 'rich_message_class'
require_relative 'rich_validation_message'

# A base class for all tests that validate sections of the AU PS Bundle
module SectionTestModule
  def entry_resources_info
    group_section_output(resolve_path_with_dar(scratch_bundle, 'entry.resource').map do |resource|
      resource_type = resolve_path_with_dar(resource, 'resourceType').first
      profiles = resolve_path_with_dar(resource, 'meta.profile').sort
      profiles.empty? ? resource_type : "#{resource_type} (#{profiles.join(', ')})"
    end).join("\n\n")
  end
end
