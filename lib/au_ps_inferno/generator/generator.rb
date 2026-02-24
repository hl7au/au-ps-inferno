# frozen_string_literal: true

require 'zlib'
require 'json'
require 'fhir_client'
require 'fhir_models'
require 'pathname'
require 'rubygems/package'
require_relative 'ig_resources_extractor'

# A class to generate test suites for the AU PS and IPS implementation guides
class Generator
  def initialize(ig_path)
    @ig_path = ig_path
    @ig_resources = []
    @metadata = {
      'composition_sections' => []
    }
  end

  def generate
    extract_resources_from_ig_package
    generate_metadata_file
  end

  private

  def extract_resources_from_ig_package
    ig_resources_extractor = IGResourcesExtractor.new(@ig_path)
    ig_resources_extractor.extract
    @ig_resources = ig_resources_extractor.ig_resources
  end

  def generate_metadata_file
    generate_metadata_for_composition
    File.write('metadata.yaml', YAML.dump(@metadata))
  end

  def generate_metadata_for_composition
    composition_structure_definition = @ig_resources.find do |resource|
      resource.resourceType == 'StructureDefinition' && resource.type == 'Composition'
    end

    return unless composition_structure_definition.present?

    elements = composition_structure_definition.snapshot.element
    sections = elements.filter do |element|
      element.path == 'Composition.section' && element.sliceName.present?
    end

    sections.each do |section|
      @metadata['composition_sections'] << {
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
  end

  def get_section_entry_data(elements, section_id)
    entries = elements.filter do |element|
      element.id.include?("#{section_id}.entry:")
    end

    entries.map do |entry|
      {
        id: entry.id,
        min: entry.min,
        max: entry.max,
        required: entry.min.positive?,
        mustSupport: entry.mustSupport || false,
        profiles: get_section_entry_profiles(entry)
      }
    end
  end

  def get_section_entry_profiles(element)
    filtered_element = element.type.filter do |type|
      type.code == 'Reference'
    end

    filtered_element.map(&:targetProfile).flatten
  end
end
