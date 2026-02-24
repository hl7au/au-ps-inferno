# frozen_string_literal: true

require 'zlib'
require 'rubygems/package'
require 'fhir_models'

class Generator
  # Extracts FHIR resources from an Implementation Guide (IG) package archive
  # and optionally from a folder of additional JSON resources.
  #
  # Reads a .tar.gz (or .tgz) package, parses JSON entries that represent FHIR
  # resources (excluding OpenAPI JSON), and populates {#ig_resources} with
  # FHIR model instances. If +additional_resources_path+ is set, all +.json+
  # files from that folder (and subfolders) are loaded after the package,
  # so you can supply missing StructureDefinitions, SearchParameters, etc.
  #
  # @example
  #   extractor = IGResourcesExtractor.new('path/to/package.tar.gz')
  #   extractor.extract
  #   extractor.ig_resources # => [FHIR::Patient, ...]
  #
  # @example With additional folder
  #   extractor = IGResourcesExtractor.new('path/to/package.tar.gz', additional_resources_path: 'path/to/extra')
  #   extractor.extract
  class IGResourcesExtractor
    # @return [Array<FHIR::Model>] FHIR resources extracted from the IG package and optional folder
    attr_reader :ig_resources

    # @param ig_path [String] Path to the IG package file (.tar.gz or .tgz)
    # @param additional_resources_path [String, nil] Optional path to a folder of JSON FHIR resources
    #   (e.g. StructureDefinition, SearchParameter) to load in addition to the package.
    def initialize(ig_path, additional_resources_path: nil)
      @ig_path = ig_path
      @additional_resources_path = additional_resources_path
      @ig_resources = []
    end

    # Processes the package archive and optional folder, and populates {#ig_resources}.
    # Handles gzip/tar errors and prints messages to stdout on failure.
    #
    # @return [void]
    def extract
      process_package_archive
      load_additional_resources_from_folder if @additional_resources_path
    end

    private

    # Opens the gzipped tar archive and iterates over tar entries.
    # @return [void]
    def process_package_archive
      Zlib::GzipReader.open(@ig_path) do |gz|
        Gem::Package::TarReader.new(gz) { |tar| process_tar(tar) }
      end
    rescue Zlib::GzipFile::Error => e
      puts_archive_error('gzip', e)
    rescue Gem::Package::TarInvalidError => e
      puts_archive_error('tar', e)
    rescue StandardError => e
      puts "Error processing archive at #{@ig_path}: #{e.message}"
    end

    # @param format_type [String] e.g. "gzip" or "tar"
    # @param error [StandardError] the raised exception
    # @return [void]
    def puts_archive_error(format_type, error)
      msg = "The file at #{@ig_path} is not a valid #{format_type} archive."
      puts "Error: #{msg} Please ensure it is a valid .tar.gz or .tgz archive."
      puts "Error details: #{error.message}"
    end

    # @param tar [Gem::Package::TarReader]
    # @return [void]
    def process_tar(tar)
      tar.each do |entry|
        next unless relevant_json_entry?(entry)

        collect_resource_from_entry(entry)
      end
    end

    # @param entry [Gem::Package::TarReader::Entry]
    # @return [Boolean] true if entry is a JSON file and not an OpenAPI JSON
    def relevant_json_entry?(entry)
      entry.file? &&
        entry.full_name.end_with?('.json') &&
        !entry.full_name.end_with?('.openapi.json')
    end

    # Parses entry content as JSON and appends a FHIR resource to {#ig_resources} if valid.
    # @param entry [Gem::Package::TarReader::Entry]
    # @return [void]
    def collect_resource_from_entry(entry)
      content = entry.read
      json = JSON.parse(content)
      return unless json.is_a?(Hash) && json['resourceType']

      @ig_resources << FHIR.from_contents(content)
    rescue StandardError => e
      puts "Error processing #{entry.full_name}: #{e.message}"
    end

    # Loads all .json files from {#additional_resources_path} (and subfolders) into {#ig_resources}.
    # Skips OpenAPI JSON files. Same validation as package entries: must be a Hash with resourceType.
    # @return [void]
    def load_additional_resources_from_folder
      path = File.expand_path(@additional_resources_path)
      unless File.directory?(path)
        puts "Error: additional resources path is not a directory: #{path}"
        return
      end

      Dir.glob(File.join(path, '**', '*.json')).each do |file_path|
        next if file_path.end_with?('.openapi.json')

        collect_resource_from_file(file_path)
      end
    end

    # @param file_path [String] Absolute path to a JSON file
    # @return [void]
    def collect_resource_from_file(file_path)
      content = File.read(file_path)
      json = JSON.parse(content)
      return unless json.is_a?(Hash) && json['resourceType']

      resource = FHIR.from_contents(content)
      puts "Resource: #{resource.resourceType} with ID: #{resource.id} is loaded from #{file_path}"

      @ig_resources << resource
    rescue StandardError => e
      puts "Error processing #{file_path}: #{e.message}"
    end
  end
end
