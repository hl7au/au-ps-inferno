# frozen_string_literal: true

require 'fhir_models'
require 'fileutils'
require 'yaml'
require_relative '../utils/inferno_suite_generator_compat'

require_relative 'metadata_manager'
require_relative 'naming'
require_relative 'sections_validation_group_generator'
require_relative 'test_file_generator'
require_relative 'generator_group_based_metadata_module'

# Generator for test suites targeting AU PS and IPS implementation guides.
#
# This class automates extraction and persistence of IG resource metadata for use in test suite
# generation, including support for additional FHIR resource folders. IG resources are loaded via
# {InfernoSuiteGenerator::Generator::IGLoader}, which reads the package archive path from
# +inferno_suite_generator.config.json+ (+ig.package_archive_path+).
#
# @example Basic usage
#   generator = Generator.new
#   generator.generate
#
# @example With extra folder containing additional FHIR resources (e.g. extra StructureDefinitions)
#   generator = Generator.new(additional_resources_path: 'path/to/extra-ig-resources')
#   generator.generate
#
class Generator
  include Naming
  include GeneratorGroupBasedMetadataModule

  def initialize(additional_resources_path: nil)
    @additional_resources_path = additional_resources_path
    register_inferno_suite_generator_config
    @ig_resources = load_ig_resources
    @core_metadata = InfernoSuiteGenerator::Generator::IGMetadataExtractor.new(@ig_resources).extract
    @composition_metadata = CompositionMetadataManager.new(@ig_resources)
  ensure
    cleanup_additional_resources_tmp_dir
  end

  def generate
    save_metadata_to_version_folder
    update_ig_version_rb(@ig_resources.ig&.version)
  end

  private

  # Loads IG resources via the shared InfernoSuiteGenerator extractor. Any additional FHIR
  # resources from {#additional_resources_path} are merged in by IGLoader itself, via the
  # +extra_json_paths+ entry that {#register_inferno_suite_generator_config} adds to the
  # registered config when {#additional_resources_path} is given.
  #
  # @return [InfernoSuiteGenerator::Generator::IGResources]
  def load_ig_resources
    config_keeper = Registry.get(:config_keeper)
    raise 'inferno_suite_generator.config.json not found; cannot load IG resources' unless config_keeper

    InfernoSuiteGenerator::Generator::IGLoader.new(config_keeper.ig_deps_path).load
  end

  def update_ig_version_rb(version)
    return if version.nil? || version.empty?

    version_rb_path = File.expand_path(File.join('lib', 'au_ps_inferno', 'version.rb'))
    content = File.read(version_rb_path)
    unless content.match?(/IG_VERSION = '.*'/)
      puts "Warning: IG_VERSION pattern not found in #{version_rb_path}; version was not updated."
      return
    end

    updated = content.gsub(/IG_VERSION = '.*'/) { "IG_VERSION = '#{version}'" }
    File.write(version_rb_path, updated) unless updated == content
  end

  def save_metadata_to_version_folder
    au_ps_inferno_dir = File.expand_path(File.join('lib', 'au_ps_inferno'))
    FileUtils.mkdir_p(File.expand_path(File.join('lib', 'au_ps_inferno')))
    @composition_metadata.initiate_build

    File.write(File.join(au_ps_inferno_dir, 'metadata.yaml'), YAML.dump(@core_metadata&.to_hash || {}))
    File.write(File.join(au_ps_inferno_dir, 'composition_metadata.yaml'), YAML.dump(@composition_metadata.composition_metadata_to_dump))
  end
end
