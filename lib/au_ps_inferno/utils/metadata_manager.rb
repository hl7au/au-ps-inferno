# frozen_string_literal: true

require 'yaml'

module AUPSTestKit
  # Manages metadata from the generated YAML files.
  #
  # Core IG-level metadata (ig_id, ig_title, groups, profiles, ...) is loaded from the given
  # +metadata_yaml_path+. Composition-specific metadata (sections, subject/author/custodian/
  # attester actor profiles) lives in a sibling +composition_metadata.yaml+ file in the same
  # directory, loaded transparently on first access. See Generator#save_metadata_to_version_folder.
  class MetadataManager
    COMPOSITION_METADATA_FILENAME = 'composition_metadata.yaml'

    def initialize(metadata_yaml_path)
      @metadata_yaml_path = metadata_yaml_path
    end

    def metadata
      @metadata ||= YAML.safe_load_file(@metadata_yaml_path, permitted_classes: [Symbol], aliases: true)
    end

    def composition_metadata
      @composition_metadata ||= YAML.safe_load_file(composition_metadata_yaml_path, permitted_classes: [Symbol],
                                                                                    aliases: true)
    end

    def sections_metadata_by_codes(codes)
      composition_sections_metadata.filter { |section| codes.include?(section[:code]) }
    end

    def group_metadata_by_resource_type(resource_type)
      group_metadata = groups_metadata.find { |group| group[:resource] == resource_type }
      return nil if group_metadata.nil?

      group_metadata
    end

    def group_metadata_by_profile_url(profile_url)
      group_metadata = groups_metadata.find { |group| group[:profile_url] == profile_url }
      return nil if group_metadata.nil?

      group_metadata
    end

    def composition_sections_metadata
      composition_metadata[:composition_sections]
    end

    def subject_metadata
      composition_metadata[:subject]
    end

    def author_metadata
      composition_metadata[:author]
    end

    def custodian_metadata
      composition_metadata[:custodian]
    end

    def attester_metadata
      composition_metadata[:attester]
    end

    def groups_metadata
      metadata[:groups]
    end

    private

    def composition_metadata_yaml_path
      File.join(File.dirname(@metadata_yaml_path), COMPOSITION_METADATA_FILENAME)
    end
  end
end
