# frozen_string_literal: true

require 'fhir_models'
require 'fileutils'
require 'yaml'
require_relative '../utils/inferno_suite_generator_compat'

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'
require_relative 'naming'
require_relative 'suite_structure'
require_relative 'test_config_registry'
require_relative 'retrieve_cs_group_generator'
require_relative 'sections_validation_group_generator'
require_relative 'test_file_generator'
require_relative 'version_suffix'
require_relative 'primitive_test'
require_relative 'primitive_group'
require_relative 'high_order_group'
require_relative 'suite_primitive'
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
  PATH_BASE = 'lib/au_ps_inferno'
  SyntheticCapability = Struct.new(
    :type, :interaction, :operation, :searchParam, :searchInclude, :searchRevInclude, :extension
  )

  include Naming
  include GeneratorGroupBasedMetadataModule

  # High-order groups are built from SuiteStructure (single source of truth).
  # See SuiteStructure and TestConfigRegistry for adding new groups or test types.
  HIGH_ORDER_GROUPS = SuiteStructure.expand_high_order_groups.freeze

  # Primitive tests expanded from SuiteStructure placeholders for AU PS vs IPS bundle validation.
  BUNDLE_VALID_TEST_TYPE_IDS = %i[bundle_valid bundle_valid_ips].freeze

  # Constructs a new Generator.
  #
  # @param ig_path [String]
  #   Path to the FHIR IG package archive (.tar.gz or .tgz).
  # @param additional_resources_path [String, nil]
  #   Optional: Path to a directory containing additional FHIR resources in JSON form
  #   (such as StructureDefinition, SearchParameter, etc.) to supplement those in the package.
  def initialize(ig_path, additional_resources_path: nil)
    register_inferno_suite_generator_config
    @resources_manager = IGResourcesExtractor.new(
      ig_path,
      additional_resources_path: additional_resources_path
    )
    @metadata = MetadataManager.new(@resources_manager.ig_resources)
    @new_metadata = build_new_metadata
  end

  # Runs the generator: extracts IG resources, writes metadata, generates bundle and section groups,
  # and generates the suite file.
  #
  # @return [void]
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
