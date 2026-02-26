# frozen_string_literal: true

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'
require_relative 'sections_validation_group_generator'
require_relative 'test_file_generator'
require_relative 'version_suffix'

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
    @suite_version = Generator.suite_version_from_ig_path(ig_path)
    @version_suffix = Generator.version_suffix(File.basename(ig_path))
    @resources_manager = IGResourcesExtractor.new(
      ig_path,
      additional_resources_path: additional_resources_path
    )
    @metadata = MetadataManager.new(@resources_manager.ig_resources)
  end

  # Runs the generator: extracts IG resources, writes metadata, generates section validation groups,
  # and generates the suite file with references to all groups.
  #
  # @return [void]
  def generate
    @resources_manager.extract
    save_metadata_to_version_folder
    group_generator = SectionsValidationGroupGenerator.new(@metadata, @version_suffix, @suite_version)
    group_generator.generate
    generate_suite([group_generator.suite_group_info])
  end

  private

  def save_metadata_to_version_folder
    return if @suite_version.empty?

    metadata_path = File.join(File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version)), 'metadata.yaml')
    @metadata.save_to_file(metadata_path)
  end

  def generate_suite(groups)
    return if @suite_version.empty?

    suite_output_base = File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version))
    config = {
      template_file_path: 'suite.rb.erb',
      output_file_path: 'au_ps_suite.rb',
      output_base: suite_output_base,
      attributes: {
        groups: groups,
        version_suffix: @version_suffix,
        suite_version: @suite_version
      }
    }
    Generator::TestFileGenerator.new(config).generate
  end
end
