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

    def subject_metadata
      metadata[:subject]
    end

    def get_subject_mandatory_elements_by_resource_type(resource_type)
      get_mandatory_elements_by_resource_type(subject_metadata, resource_type) || []
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

    def get_attester_mandatory_elements_by_resource_type(resource_type)
      get_mandatory_elements_by_resource_type(attester_metadata, resource_type) || []
    end

    def entities_from_metadata_items(metadata_items)
      return normalize_entities_array(metadata_items || []) unless metadata_items.is_a?(Hash)
      return [metadata_items] if resource_entity?(metadata_items)

      normalize_entities_array(fetch_entities(metadata_items))
    end

    def resource_entity?(metadata_item)
      metadata_item.key?(:resource_type) || metadata_item.key?('resource_type')
    end

    def fetch_entities(metadata_item)
      metadata_item.fetch(:entities, metadata_item.fetch('entities', []))
    end

    def normalize_entities_array(entities)
      entities.is_a?(Hash) ? [entities] : entities
    end

    def filter_mandatory_elements(elements)
      elements.filter do |element|
        (element[:min] || element['min']).to_i.positive?
      end
    end

    def map_elements_to_expressions(elements)
      elements.map { |element| element[:expression] || element['expression'] }
    end

    def get_mandatory_elements_by_resource_type(metadata_items, resource_type)
      entities = entities_from_metadata_items(metadata_items)

      metadata_item = entities.find { |entity| (entity[:resource_type] || entity['resource_type']) == resource_type }
      return [] unless metadata_item

      filtered_elements = filter_mandatory_elements(metadata_item[:elements] || metadata_item['elements'] || [])
      map_elements_to_expressions(filtered_elements)
    end
  end
end
