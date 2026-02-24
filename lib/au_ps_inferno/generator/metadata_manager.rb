# frozen_string_literal: true

require 'yaml'

# Builds and persists metadata for Composition sections from IG resources.
#
# Extracts Composition StructureDefinition sections and their entry constraints
# (profiles, cardinality, mustSupport, section codes) and serializes them to YAML.
class MetadataManager
  # @param ig_resources [Array<FHIR::Model>] Parsed IG resources (e.g. from IGResourcesExtractor#ig_resources)
  def initialize(ig_resources)
    @ig_resources = ig_resources
    @composition_sections = []
  end

  # Generates composition section metadata from IG resources (in-memory only).
  # Populates the internal composition sections used by {#save_to_file}.
  # @return [void]
  def initiate_build
    generate_metadata_for_composition
  end

  # Builds composition metadata and writes it to a YAML file.
  # Calls {#initiate_build} first, then serializes {composition_sections: ...} to YAML.
  # @param file_path [String] Path to the output YAML file (e.g. +metadata.yaml+)
  # @return [void]
  def save_to_file(file_path)
    initiate_build
    File.write(file_path, YAML.dump({ composition_sections: @composition_sections }))
  end

  private

  # @param type [String] FHIR resource type (e.g. +StructureDefinition+)
  # @return [Array<FHIR::Model>]
  def get_resources_by_type(type)
    @ig_resources.filter do |resource|
      resource.resourceType == type
    end
  end

  # @param type [String] Logical type (e.g. +Composition+)
  # @return [FHIR::StructureDefinition, nil]
  def get_structure_definition_by_type(type)
    get_resources_by_type('StructureDefinition').find do |resource|
      resource.type == type
    end
  end

  # Populates @composition_sections from the Composition StructureDefinition.
  # No-op when no Composition StructureDefinition is present in the IG.
  # @return [void]
  def generate_metadata_for_composition
    composition_structure_definition = get_structure_definition_by_type('Composition')
    return if composition_structure_definition.nil?

    elements = composition_structure_definition.snapshot.element
    sections = elements.filter do |element|
      element.path == 'Composition.section' && !element.sliceName.nil?
    end

    sections.each do |section|
      @composition_sections << build_section_data(section, elements)
    end
  end

  # @param section [FHIR::Element] Snapshot element for Composition.section (with sliceName)
  # @param elements [Array<FHIR::Element>] All snapshot elements from the Composition StructureDefinition
  # @return [Hash{Symbol => Object}] Section metadata (+:id+, +:short+, +:definition+, +:min+, +:max+, +:required+, +:mustSupport+, +:code+, +:entries+)
  def build_section_data(section, elements)
    basic_section_data = build_basic_section_data(section)
    {
      **basic_section_data,
      code: section_code(section.id, elements),
      entries: get_section_entry_data(elements, section.id)
    }
  end

  # @param section [FHIR::Element] Snapshot element for Composition.section (with sliceName)
  # @return [Hash{Symbol => Object}] Basic section fields (+:id+, +:short+, +:definition+, +:min+, +:max+, +:required+, +:mustSupport+)
  def build_basic_section_data(section)
    {
      id: section.id,
      short: section.short,
      definition: section.definition,
      min: section.min,
      max: section.max,
      required: section.min.positive?,
      mustSupport: section.mustSupport || false
    }
  end

  # Extracts the LOINC (or other) section code from the section's +code+ element.
  # @param section_id [String] Section element id (e.g. +Composition.section:sectionProblems+)
  # @param elements [Array<FHIR::Element>] All snapshot elements
  # @return [String, nil] First coding code from the section's pattern CodeableConcept, or nil if absent
  def section_code(section_id, elements)
    filtered_element = elements.find do |element|
      element.id == "#{section_id}.code"
    end
    return nil if filtered_element.nil?

    filtered_element.patternCodeableConcept.coding.first.code
  end

  # @param elements [Array<FHIR::Element>] Snapshot elements
  # @param section_id [String] Section element id (e.g. +Composition.section:sectionProblems+)
  # @return [Array<Hash>] Entry metadata hashes (see {#build_section_entry_data})
  def get_section_entry_data(elements, section_id)
    entries = elements.filter do |element|
      element.id.include?("#{section_id}.entry:")
    end

    entries.map do |entry|
      build_section_entry_data(entry)
    end
  end

  # @param entry [FHIR::Element] Snapshot element for a section entry (e.g. +Composition.section:sectionProblems.entry:problem+)
  # @return [Hash{Symbol => Object}] Entry metadata (+:id+, +:min+, +:max+, +:required+, +:mustSupport+, +:profiles+)
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

  # @param element [FHIR::Element] Snapshot element with type Reference and targetProfile
  # @return [Array<String>] Target profile URLs for the Reference type(s)
  def get_section_entry_profiles(element)
    filtered_element = element.type.filter do |type|
      type.code == 'Reference'
    end

    filtered_element.map(&:targetProfile).flatten
  end
end
