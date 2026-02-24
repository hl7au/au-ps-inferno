# frozen_string_literal: true

require 'yaml'

# Builds and persists metadata for Composition sections from IG resources.
#
# Extracts Composition StructureDefinition sections and their entry constraints
# (profiles, cardinality, mustSupport) and can serialize them to YAML.
class MetadataManager
  # @param ig_resources [Array<Object>] Parsed IG resources (e.g. from IgResourcesExtractor)
  def initialize(ig_resources)
    @ig_resources = ig_resources
    @composition_sections = []
  end

  # Generates composition section metadata from IG resources (in-memory only).
  # @return [void]
  def initiate_build
    generate_metadata_for_composition
  end

  # Builds composition metadata and writes it to a YAML file.
  # @param file_path [String] Path to the output YAML file
  # @return [void]
  def save_to_file(file_path)
    initiate_build
    File.write(file_path, YAML.dump({ composition_sections: @composition_sections }))
  end

  private

  # @param type [String] FHIR resource type (e.g. 'StructureDefinition')
  # @return [Array<Object>]
  def get_resources_by_type(type)
    @ig_resources.filter do |resource|
      resource.resourceType == type
    end
  end

  # @param type [String] Logical type (e.g. 'Composition')
  # @return [Object, nil] StructureDefinition or nil
  def get_structure_definition_by_type(type)
    get_resources_by_type('StructureDefinition').find do |resource|
      resource.type == type
    end
  end

  # Populates @composition_sections from the Composition StructureDefinition.
  # @return [void]
  def generate_metadata_for_composition
    composition_structure_definition = get_structure_definition_by_type('Composition')

    elements = composition_structure_definition.snapshot.element
    sections = elements.filter do |element|
      element.path == 'Composition.section' && !element.sliceName.nil?
    end

    sections.each do |section|
      @composition_sections << build_section_data(section, elements)
    end
  end

  # @param section [Object] Snapshot element for Composition.section (with sliceName)
  # @param elements [Array<Object>] All snapshot elements
  # @return [Hash] Section metadata (id, short, definition, min, max, required, mustSupport, entries)
  def build_section_data(section, elements)
    {
      id: section.id,
      short: section.short,
      definition: section.definition,
      min: section.min,
      max: section.max,
      required: section.min.positive?,
      mustSupport: section.mustSupport || false,
      entries: get_section_entry_data(elements, section.id)
    }
  end

  # @param elements [Array<Object>] Snapshot elements
  # @param section_id [String] Section id (e.g. 'Composition.section')
  # @return [Array<Hash>] Entry metadata hashes
  def get_section_entry_data(elements, section_id)
    entries = elements.filter do |element|
      element.id.include?("#{section_id}.entry:")
    end

    entries.map do |entry|
      build_section_entry_data(entry)
    end
  end

  # @param entry [Object] Snapshot element for a section entry
  # @return [Hash] Entry metadata (id, min, max, required, mustSupport, profiles)
  def build_section_entry_data(entry)
    {
      id: entry.id,
      min: entry.min,
      max: entry.max,
      required: entry.min.positive?,
      mustSupport: entry.mustSupport || false,
      profiles: get_section_entry_profiles(entry)
    }
  end

  # @param element [Object] Snapshot element with type (Reference) and targetProfile
  # @return [Array<String>] Target profile URLs
  def get_section_entry_profiles(element)
    filtered_element = element.type.filter do |type|
      type.code == 'Reference'
    end

    filtered_element.map(&:targetProfile).flatten
  end
end
