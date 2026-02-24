# frozen_string_literal: true

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'

# Generates test suites for the AU PS and IPS implementation guides.
#
# Extracts and persists resource metadata for use in test suite generation.
#
# @example
#   generator = Generator.new('/path/to/ig')
#   generator.generate
#
# @example With additional resources folder (e.g. missing StructureDefinitions)
#   generator = Generator.new('/path/to/ig', additional_resources_path: 'path/to/extra-ig-resources')
#   generator.generate
class Generator
  # Initializes a Generator with a given IG package path and optional folder for extra resources.
  #
  # @param ig_path [String] Path to the IG package file (.tar.gz or .tgz).
  # @param additional_resources_path [String, nil] Optional path to a folder of JSON FHIR resources
  #   (StructureDefinition, SearchParameter, etc.) to load in addition to the package.
  def initialize(ig_path, additional_resources_path: nil)
    @ig_path = ig_path
    @resources_manager = IGResourcesExtractor.new(ig_path, additional_resources_path: additional_resources_path)
    @metadata = MetadataManager.new(@resources_manager.ig_resources)
  end

  # Extract resources and save metadata to a YAML file.
  #
  # @return [void]
  def generate
    @resources_manager.extract
    @metadata.save_to_file('metadata.yaml')
  end
end
