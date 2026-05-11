# frozen_string_literal: true

require 'fhir_models'
require 'fileutils'
require 'yaml'
require_relative '../utils/inferno_suite_generator_compat'

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'
require_relative 'naming'
require_relative 'sections_validation_group_generator'
require_relative 'test_file_generator'
require_relative 'generator_group_based_metadata_module'

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
#
# rubocop:disable Metrics/ClassLength -- orchestration class; primitive helpers kept private below
class Generator
  SyntheticCapability = Struct.new(
    :type, :interaction, :operation, :searchParam, :searchInclude, :searchRevInclude, :extension
  )

  include Naming
  include GeneratorGroupBasedMetadataModule

  def initialize(ig_path, additional_resources_path: nil)
    register_inferno_suite_generator_config
    @resources_manager = IGResourcesExtractor.new(
      ig_path,
      additional_resources_path: additional_resources_path
    )
    @metadata = MetadataManager.new(@resources_manager.ig_resources)
    @new_metadata = build_new_metadata
  end

  def generate
    @resources_manager.extract
    save_metadata_to_version_folder
  end

  private

  def save_metadata_to_version_folder
    metadata_path = File.join(File.expand_path(File.join('lib', 'au_ps_inferno')), 'metadata.yaml')
    FileUtils.mkdir_p(File.dirname(metadata_path))
    @metadata.initiate_build
    old_metadata = @metadata.metadata_to_dump
    new_metadata = @new_metadata&.to_hash || {}
    merged_metadata = merge_metadata_values(old_metadata, new_metadata)
    File.write(metadata_path, YAML.dump(merged_metadata))
  end
end
# rubocop:enable Metrics/ClassLength
