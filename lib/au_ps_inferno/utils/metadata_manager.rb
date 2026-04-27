# frozen_string_literal: true

require 'yaml'

module AUPSTestKit
  # Manages metadata from the ballot YAML file.
  class MetadataManager
    def initialize(metadata_yaml_path)
      @metadata_yaml_path = metadata_yaml_path
    end

    def metadata
      @metadata ||= YAML.safe_load_file(@metadata_yaml_path, permitted_classes: [Symbol], aliases: true)
    end

    def sections_metadata_by_codes(codes)
      composition_sections_metadata.filter { |section| codes.include?(section[:code]) }
    end

    def section_metadata_by_code(code)
      composition_sections_metadata.find { |section| section[:code] == code }
    end

    def required_ms_sections_metadata
      composition_sections_metadata.filter { |section| section[:required] == true && section[:mustSupport] == true }
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
      metadata[:composition_sections]
    end

    def subject_metadata
      metadata[:subject]
    end

    def author_metadata
      metadata[:author]
    end

    def custodian_metadata
      metadata[:custodian]
    end

    def attester_metadata
      metadata[:attester]
    end

    def groups_metadata
      metadata[:groups]
    end
  end
end
