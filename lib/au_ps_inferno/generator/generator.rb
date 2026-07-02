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
require_relative 'hand_authored_groups_generator'

# Generator for test suites targeting AU PS and IPS implementation guides.
#
# This class automates extraction and persistence of IG resource metadata, and generation of a
# version-specific test suite folder (lib/au_ps_inferno/<ig_version>/), for use in test suite
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
class Generator
  SyntheticCapability = Struct.new(
    :type, :interaction, :operation, :searchParam, :searchInclude, :searchRevInclude, :extension
  )

  include Naming
  include GeneratorGroupBasedMetadataModule

  def initialize(ig_path, additional_resources_path: nil)
    @ig_path = ig_path
    @resources_manager = IGResourcesExtractor.new(
      ig_path,
      additional_resources_path: additional_resources_path
    )
    @metadata = MetadataManager.new(@resources_manager.ig_resources)
  end

  # Extracts the IG package, then generates everything for that IG version:
  # metadata.yaml, the hand-authored group families (bundle instance, retrieve CS group,
  # retrieve/generate bundle validation tests), and the top-level suite file, all under
  # lib/au_ps_inferno/<ig_version>/. Finally updates the default IG_VERSION constant.
  #
  # @return [void]
  def generate
    @resources_manager.extract
    @suite_version = @resources_manager.ig_version
    register_inferno_suite_generator_config(@suite_version, @ig_path)
    @new_metadata = build_new_metadata
    save_metadata_to_version_folder
    groups = HandAuthoredGroupsGenerator.new(@suite_version, reformatted_version(@suite_version)).generate
    generate_suite_file(groups)
    update_ig_version_rb(@suite_version)
  end

  private

  def update_ig_version_rb(version)
    return if version.nil? || version.empty?

    version_rb_path = File.expand_path(File.join('lib', 'au_ps_inferno', 'version.rb'))
    content = File.read(version_rb_path)
    updated = content.gsub(/IG_VERSION = '.*'/) { "IG_VERSION = '#{version}'" }
    if updated == content
      puts "Warning: IG_VERSION pattern not found in #{version_rb_path}; version was not updated."
      return
    end
    File.write(version_rb_path, updated)
  end

  def version_output_dir
    File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version))
  end

  def save_metadata_to_version_folder
    metadata_path = File.join(version_output_dir, 'metadata.yaml')
    FileUtils.mkdir_p(File.dirname(metadata_path))
    @metadata.initiate_build
    old_metadata = @metadata.metadata_to_dump
    new_metadata = @new_metadata&.to_hash || {}
    merged_metadata = merge_metadata_values(old_metadata, new_metadata)
    File.write(metadata_path, YAML.dump(merged_metadata))
  end

  # Builds the config hash used to render the top-level per-version suite file.
  #
  # @param class_name [String] versioned suite class name (e.g. "AUPSSuite100ballot")
  # @param id [Symbol] versioned suite id (e.g. :suite_100ballot)
  # @param reformatted_version [String] compact version suffix (e.g. "100ballot")
  # @param groups [Array<Hash>] group entries, see {HandAuthoredGroupsGenerator#generate}
  # @return [Hash]
  def suite_primitive_config(class_name, id, reformatted_version, groups)
    {
      class_name: class_name,
      id: id,
      reformatted_version: reformatted_version,
      suite_version: @suite_version,
      groups: groups,
      output_file_path: File.join('lib', 'au_ps_inferno', @suite_version.to_s, "#{reformatted_version}_suite.rb")
    }
  end

  def generate_suite_file(groups)
    reformatted = reformatted_version(@suite_version)
    class_name = versioned_class_name('AUPSSuite', reformatted)
    id = versioned_id('suite', reformatted).to_sym
    config = suite_primitive_config(class_name, id, reformatted, groups)

    TestFileGenerator.new(
      template_file_path: 'suite.rb.erb',
      output_file_path: config[:output_file_path],
      output_base: File.expand_path('.'),
      attributes: {
        class_name: config[:class_name],
        suite_id: config[:id],
        suite_version: config[:suite_version],
        groups: config[:groups]
      }
    ).generate
  end
end
