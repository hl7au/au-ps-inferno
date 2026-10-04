# frozen_string_literal: true

require 'fhir_models'
require 'fileutils'
require 'json'
require 'yaml'
require_relative '../utils/inferno_suite_generator_compat'

require_relative 'metadata_manager'
require_relative 'naming'
require_relative 'sections_validation_group_generator'
require_relative 'test_file_generator'
require_relative 'generator_group_based_metadata_module'

# Generator for test suites targeting AU PS and IPS implementation guides.
#
# The kit carries one suite per AU PS IG version. Each version has its own generator config,
# +config.<key>.json+ in the repository root, whose +ig+ block names the
# package archive to read (+ig.package_archive_path+) and whose +kit.suite_file+ names the suite
# class for that version. Generating a version writes its metadata to
# +lib/au_ps_inferno/generated/<key>/metadata.yaml+ and +composition_metadata.yaml+ and sets the
# +IG_VERSION+ constant in its suite class to the version declared in the package. Versions are
# generated independently, so regenerating one never touches another.
#
# @example Generate every configured version
#   Generator.version_keys.each { |key| Generator.new(version_key: key).generate }
#
# @example Generate one version with extra StructureDefinitions merged in
#   Generator.new(version_key: 'ci-build', additional_resources_path: 'additional_resources').generate
#
class Generator
  include Naming
  include GeneratorGroupBasedMetadataModule

  ROOT_DIR = File.expand_path('../../..', __dir__)
  CONFIG_FILE_PREFIX = 'config.'
  CONFIG_FILE_SUFFIX = '.json'

  class << self
    # @return [Array<String>] the key of every version that has a generator config, sorted
    def version_keys(root_dir = ROOT_DIR)
      Dir.glob(File.join(root_dir, "#{CONFIG_FILE_PREFIX}*#{CONFIG_FILE_SUFFIX}"))
         .map { |path| File.basename(path).delete_prefix(CONFIG_FILE_PREFIX).delete_suffix(CONFIG_FILE_SUFFIX) }
         .sort
    end

    # @return [String] absolute path of the generator config for +version_key+
    def config_path_for(version_key, root_dir = ROOT_DIR)
      File.join(root_dir, "#{CONFIG_FILE_PREFIX}#{version_key}#{CONFIG_FILE_SUFFIX}")
    end

    # A CI-build version (one whose config has a +ci_build+ section) is generated from a
    # package that rake au_ps:ci_build:download fetches and nothing commits, so a plain
    # regeneration of every version skips it.
    #
    # @return [Boolean]
    def ci_build?(version_key, root_dir = ROOT_DIR)
      JSON.parse(File.read(config_path_for(version_key, root_dir))).key?('ci_build')
    end
  end

  attr_reader :version_key

  def initialize(version_key:, additional_resources_path: nil, root_dir: ROOT_DIR)
    @version_key = version_key
    @root_dir = root_dir
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
    update_suite_ig_version(@ig_resources.ig&.version)
  end

  private

  def inferno_suite_generator_config_path
    path = self.class.config_path_for(version_key, @root_dir)
    raise ArgumentError, "No generator config for AU PS version #{version_key.inspect}: #{path}" unless File.exist?(path)

    path
  end

  def version_config
    @version_config ||= JSON.parse(File.read(inferno_suite_generator_config_path))
  end

  # Loads IG resources via the shared InfernoSuiteGenerator extractor. Any additional FHIR
  # resources from {#additional_resources_path} are merged in by IGLoader itself, via the
  # +extra_json_paths+ entry that {#register_inferno_suite_generator_config} adds to the
  # registered config when {#additional_resources_path} is given.
  #
  # IGLoader skips a missing archive without complaint, which would generate empty metadata,
  # so the archive is checked here first.
  #
  # @return [InfernoSuiteGenerator::Generator::IGResources]
  def load_ig_resources
    archive_path = version_config.dig('ig', 'package_archive_path')
    full_archive_path = archive_path && File.expand_path(archive_path, @root_dir)
    unless full_archive_path && File.exist?(full_archive_path)
      raise ArgumentError, "IG package archive for AU PS version #{version_key.inspect} not found: #{archive_path.inspect}"
    end

    Dir.chdir(@root_dir) do
      InfernoSuiteGenerator::Generator::IGLoader.new(Registry.get(:config_keeper).ig_deps_path).load
    end
  end

  # Sets +IG_VERSION = '<version>'+ in the version's suite class (+kit.suite_file+).
  def update_suite_ig_version(version)
    return if version.nil? || version.empty?

    suite_file = version_config.dig('kit', 'suite_file')
    raise ArgumentError, "Generator config for #{version_key.inspect} has no kit.suite_file" unless suite_file

    suite_path = File.expand_path(suite_file, @root_dir)
    content = File.read(suite_path)
    raise ArgumentError, "IG_VERSION constant not found in #{suite_path}" unless content.match?(/IG_VERSION = '.*'/)

    updated = content.sub(/IG_VERSION = '.*'/) { "IG_VERSION = '#{version}'" }
    File.write(suite_path, updated) unless updated == content
  end

  def save_metadata_to_version_folder
    output_dir = File.join(@root_dir, 'lib', 'au_ps_inferno', 'generated', version_key)
    FileUtils.mkdir_p(output_dir)
    @composition_metadata.initiate_build

    File.write(File.join(output_dir, 'metadata.yaml'), YAML.dump(@core_metadata&.to_hash || {}))
    File.write(File.join(output_dir, 'composition_metadata.yaml'), YAML.dump(@composition_metadata.composition_metadata_to_dump))
  end
end
