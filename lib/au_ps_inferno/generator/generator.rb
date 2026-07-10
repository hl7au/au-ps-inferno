# frozen_string_literal: true

require 'fhir_models'
require 'fileutils'
require 'yaml'
require_relative '../utils/inferno_suite_generator_compat'

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'
require_relative 'naming'
require_relative 'suite_file_generator'
require_relative 'test_file_generator'
require_relative 'generator_group_based_metadata_module'
require_relative 'generated_manifest'

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
class Generator
  SyntheticCapability = Struct.new(
    :type, :interaction, :operation, :searchParam, :searchInclude, :searchRevInclude, :extension
  )

  # The 1.0.0 suite (lib/au_ps_inferno/suite/) is hand-authored and is never regenerated.
  LEGACY_IG_VERSION = SuiteFileGenerator::LEGACY_IG_VERSION

  include Naming
  include GeneratorGroupBasedMetadataModule

  def initialize(ig_path, additional_resources_path: nil)
    register_inferno_suite_generator_config
    @ig_path = ig_path
    @resources_manager = IGResourcesExtractor.new(
      ig_path,
      additional_resources_path: additional_resources_path
    )
    @metadata = MetadataManager.new(@resources_manager.ig_resources)
    @new_metadata = build_new_metadata
  end

  # Extracts the IG package and, for any version other than the hand-authored 1.0.0, writes
  # lib/au_ps_inferno/generated/<ig_version>/metadata.yaml plus a full generated suite tree
  # alongside it. Records the archive in lib/au_ps_inferno/igs/generated.yaml either way, so
  # `rake generator:pending` doesn't keep flagging it.
  #
  # @return [void]
  def generate
    @resources_manager.extract
    ig_version = @resources_manager.ig_version

    if ig_version.nil? || ig_version.empty?
      warn "Could not determine an IG version from #{@ig_path}; nothing generated."
      return
    end

    if ig_version == LEGACY_IG_VERSION
      warn "Skipping generation for #{LEGACY_IG_VERSION}: its suite under lib/au_ps_inferno/suite/ " \
           'is hand-authored and is not regenerated.'
    else
      save_metadata_to_version_folder(ig_version)
      SuiteFileGenerator.new(@metadata, ig_version, lib_au_ps_inferno_root).generate
    end

    record_generated_archive(ig_version)
  end

  private

  def lib_au_ps_inferno_root
    File.expand_path(File.join('lib', 'au_ps_inferno'))
  end

  def record_generated_archive(ig_version)
    GeneratedManifest.new(File.join(lib_au_ps_inferno_root, 'igs')).record(@ig_path, ig_version)
  end

  def save_metadata_to_version_folder(ig_version)
    metadata_path = File.join(lib_au_ps_inferno_root, 'generated', ig_version, 'metadata.yaml')
    FileUtils.mkdir_p(File.dirname(metadata_path))
    @metadata.initiate_build
    old_metadata = @metadata.metadata_to_dump
    new_metadata = @new_metadata&.to_hash || {}
    merged_metadata = merge_metadata_values(old_metadata, new_metadata)
    merged_metadata[:ig_version] = ig_version
    File.write(metadata_path, YAML.dump(merged_metadata))
  end
end
