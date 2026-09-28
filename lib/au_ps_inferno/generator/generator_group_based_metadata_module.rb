# frozen_string_literal: true

require 'json'
require 'tmpdir'
require 'fileutils'

class Generator
  # Module for building group-based metadata
  module GeneratorGroupBasedMetadataModule
    private

    # Registers a config keeper for this generator's version, replacing any keeper a previous
    # generator registered, so generating several versions in one process never reads another
    # version's config.
    def register_inferno_suite_generator_config
      keeper = InfernoSuiteGenerator::Generator::GeneratorConfigKeeper.new(
        config_file_paths(inferno_suite_generator_config_path)
      )
      Registry.register(:config_keeper, keeper)
    end

    # Builds the config_file_paths array passed to GeneratorConfigKeeper. When
    # {#additional_resources_path} is given, appends a generated config pointing IGLoader's
    # +extra_json_paths+ mechanism at a Bundle wrapping those resources, so the gem's own
    # loading logic (rather than a bespoke copy of it) picks them up.
    #
    # @param config_path [String] Path to the version's config.<key>.json
    # @return [Array<String>]
    def config_file_paths(config_path)
      paths = [config_path]
      extra_config_path = additional_resources_extra_config_path if @additional_resources_path
      paths << extra_config_path if extra_config_path
      paths
    end

    # @return [String, nil] Path to a generated config file setting +suite.extra_json_paths+,
    #   or nil if no additional resources were found.
    def additional_resources_extra_config_path
      bundle_path = write_additional_resources_bundle
      return nil unless bundle_path

      config_path = File.join(additional_resources_tmp_dir, 'extra_json_paths.config.json')
      File.write(config_path, JSON.generate(suite: { extra_json_paths: [bundle_path] }))
      config_path
    end

    # Wraps every JSON resource under {#additional_resources_path} in a single FHIR Bundle.
    # IGLoader#load_ig unconditionally calls +.entry+ on every file it loads via
    # +extra_json_paths+, so plain (non-Bundle) resource files must be wrapped first.
    #
    # @return [String, nil] Path to the generated Bundle file, or nil if the folder doesn't
    #   exist or contains no valid FHIR resources.
    def write_additional_resources_bundle
      source_dir = File.expand_path(@additional_resources_path)
      unless File.directory?(source_dir)
        warn "Additional resources path is not a directory: #{source_dir}"
        return nil
      end

      entries = additional_resources_bundle_entries(source_dir)
      return nil if entries.empty?

      bundle_path = File.join(additional_resources_tmp_dir, 'additional_resources_bundle.json')
      File.write(bundle_path, JSON.generate(resourceType: 'Bundle', type: 'collection', entry: entries))
      bundle_path
    end

    # @param source_dir [String] Directory to recursively search for *.json resource files
    # @return [Array<Hash>] Bundle entry hashes (skips OpenAPI JSON files and invalid JSON)
    def additional_resources_bundle_entries(source_dir)
      Dir.glob(File.join(source_dir, '**', '*.json')).filter_map do |file_path|
        next if file_path.end_with?('.openapi.json')

        resource_json = JSON.parse(File.read(file_path))
        next unless resource_json.is_a?(Hash) && resource_json['resourceType']

        { resource: resource_json }
      rescue JSON::ParserError => e
        warn "Error parsing #{file_path}: #{e.message}"
        nil
      end
    end

    def additional_resources_tmp_dir
      @additional_resources_tmp_dir ||= Dir.mktmpdir('au_ps_additional_resources')
    end

    def cleanup_additional_resources_tmp_dir
      return unless @additional_resources_tmp_dir

      FileUtils.remove_entry(@additional_resources_tmp_dir)
      @additional_resources_tmp_dir = nil
    end
  end
end
