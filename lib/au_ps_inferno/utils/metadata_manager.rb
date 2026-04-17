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

    def required_ms_sections_metadata
      composition_sections_metadata.filter { |section| section[:required] == true && section[:mustSupport] == true }
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
  end
end
