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
    @metadata = MetadataManager.new(@ig_resources)
    @new_metadata = build_new_metadata
    @core_metadata = InfernoSuiteGenerator::Generator::IGMetadataExtractor.new(@ig_resources).extract
    @composition_metadata = MetadataManager.new(@ig_resources)
  end

  def generate
    save_metadata_to_version_folder
    update_ig_version_rb(@ig_resources.ig&.version)
  end

  private

  # Loads IG resources via the shared InfernoSuiteGenerator extractor, then merges in any
  # additional FHIR resources (e.g. base FHIR/IPS StructureDefinitions not present in the IG
  # package) from {#additional_resources_path}, if given.
  #
  # @return [InfernoSuiteGenerator::Generator::IGResources]
  def load_ig_resources
    config_keeper = Registry.get(:config_keeper)
    ig_resources = InfernoSuiteGenerator::Generator::IGLoader.new(config_keeper.ig_deps_path).load
    load_additional_resources(ig_resources) if @additional_resources_path
    ig_resources
  end

  # Loads all .json files from {#additional_resources_path} (and subfolders) into +ig_resources+.
  # Skips OpenAPI JSON files. Must be a Hash with resourceType.
  #
  # @param ig_resources [InfernoSuiteGenerator::Generator::IGResources]
  # @return [void]
  def load_additional_resources(ig_resources)
    path = File.expand_path(@additional_resources_path)
    unless File.directory?(path)
      puts "Error: additional resources path is not a directory: #{path}"
      return
    end

    Dir.glob(File.join(path, '**', '*.json')).each do |file_path|
      next if file_path.end_with?('.openapi.json')

      add_resource_from_file(ig_resources, file_path)
    end
  end

  # @param ig_resources [InfernoSuiteGenerator::Generator::IGResources]
  # @param file_path [String] Absolute path to a JSON file
  # @return [void]
  def add_resource_from_file(ig_resources, file_path)
    content = File.read(file_path)
    json = JSON.parse(content)
    return unless json.is_a?(Hash) && json['resourceType']

    resource = FHIR.from_contents(content)
    puts "Resource: #{resource.resourceType} with ID: #{resource.id} is loaded from #{file_path}"

    ig_resources.add(resource)
  rescue StandardError => e
    puts "Error processing #{file_path}: #{e.message}"
  end

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

  def save_metadata_to_version_folder
    au_ps_inferno_dir = File.expand_path(File.join('lib', 'au_ps_inferno'))
    FileUtils.mkdir_p(File.expand_path(File.join('lib', 'au_ps_inferno')))
    @composition_metadata.initiate_build

    File.write(File.join(au_ps_inferno_dir, 'metadata.yaml'), YAML.dump(@core_metadata&.to_hash || {}))
    File.write(File.join(au_ps_inferno_dir, 'composition_metadata.yaml'), YAML.dump(@composition_metadata.composition_metadata_to_dump))
  end
end
