# frozen_string_literal: true

require 'zlib'
require 'json'
require 'fhir_client'
require 'fhir_models'
require 'pathname'
require 'rubygems/package'

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
    # Implement the logic to generate the test suite
    # 1. Get IG Package, extract all provided resources from the archive
    extract_resources_from_ig_package
    # 2. Generate metadata file for the test suite purposes.
    # 2.1 Composition sections information: provided sections (title, code, entries (profile, resourceType))
    generate_metadata_file
  end

  private

  def extract_resources_from_ig_package
    # 1. Open *.tgz file
    # 2. Extract all FHIR resources from the archive
    # 3. Save the resources to the @ig_resources array
    process_package_archive
    puts "Extracted #{@ig_resources.count} FHIR resources from IG package"
  end

  def generate_metadata_file
    # Implement the logic to generate the metadata file
    generate_metadata_for_composition
    # Save the metadatq to the file in YAML format
    File.write('metadata.yaml', YAML.dump(@metadata))
  end

  def generate_metadata_for_composition
    # 1. Get information about each section provided in the Section StructureDefinition resource
    # "id": "Composition.section:sectionProblems.entry:problem",
    # StructureDefinition.snapshot.element.where(id='Composition.section:sectionProblems.entry:problem')
    # StructureDefinition.snapshot.element.where(id='Composition.section:sectionProblems.entry:problem').short
    # StructureDefinition.snapshot.element.where(id='Composition.section:sectionProblems.entry:problem').definition
    # StructureDefinition.snapshot.element.where(id='Composition.section:sectionProblems.entry:problem').max
    # StructureDefinition.snapshot.element.where(id='Composition.section:sectionProblems.entry:problem').min
    # StructureDefinition.snapshot.element.where(id='Composition.section:sectionProblems.entry:problem').mustSupport
    # StructureDefinition.snapshot.element.where(id='Composition.section:sectionProblems.entry:problem').type.where(code='Reference').targetProfile
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

  def process_package_archive
    Zlib::GzipReader.open(@ig_path) do |gz|
      Gem::Package::TarReader.new(gz) do |tar|
        tar.each do |entry|
          next unless entry.file? && entry.full_name.end_with?('.json')
          next if entry.full_name.end_with?('.openapi.json')

          begin
            content = entry.read
            json = JSON.parse(content)

            next unless json.is_a?(Hash) && json['resourceType']

            resource = FHIR.from_contents(content)

            @ig_resources << resource
          rescue StandardError => e
            puts "Error processing #{entry.full_name}: #{e.message}"
          end
        end
      end
    end
  rescue Zlib::GzipFile::Error => e
    puts "Error: The file at #{archive_path} is not a valid gzip file. Please ensure it is a valid .tar.gz or .tgz archive."
    puts "Error details: #{e.message}"
  rescue Gem::Package::TarInvalidError => e
    puts "Error: The file at #{archive_path} is not a valid tar archive. Please ensure it is a valid .tar.gz or .tgz archive."
    puts "Error details: #{e.message}"
  rescue StandardError => e
    puts "Error processing archive at #{archive_path}: #{e.message}"
  end
end
