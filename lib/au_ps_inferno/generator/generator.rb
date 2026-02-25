# frozen_string_literal: true

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'
require_relative 'sections_validation_group_generator'

# Generator for test suites targeting AU PS and IPS implementation guides.
#
# This class automates extraction and persistence of IG resource metadata for use in test suite
# generation, including support for additional FHIR resource folders.
#
# @example Basic usage
#   generator = Generator.new('/path/to/ig')
#   generator.generate
#
# @example With extra folder containing additional FHIR resources (e.g. extra StructureDefinitions)
#   generator = Generator.new('/path/to/ig', additional_resources_path: 'path/to/extra-ig-resources')
#   generator.generate
class Generator
  # Constructs a new Generator.
  #
  # @param ig_path [String]
  #   Path to the FHIR IG package archive (.tar.gz or .tgz).
  # @param additional_resources_path [String, nil]
  #   Optional: Path to a directory containing additional FHIR resources in JSON form
  #   (such as StructureDefinition, SearchParameter, etc.) to supplement those in the package.
  def initialize(ig_path, additional_resources_path: nil)
    @ig_path = ig_path
    @resources_manager = IGResourcesExtractor.new(
      ig_path,
      additional_resources_path: additional_resources_path
    )
    @metadata = MetadataManager.new(@resources_manager.ig_resources)
  end

  # Runs the generator: extracts IG resources, writes metadata, and generates section validation groups.
  #
  # @return [void]
  def generate
    @resources_manager.extract
    @metadata.save_to_file('metadata.yaml')
    SectionsValidationGroupGenerator.new(@metadata).generate
  end
end
