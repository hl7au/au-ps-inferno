# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'naming'

class Generator
  # Module for building group-based metadata
  module GeneratorGroupBasedMetadataModule
    private

    def build_new_metadata
      config_keeper = Registry.get(:config_keeper)
      return nil unless config_keeper

      ig_resources = InfernoSuiteGenerator::Generator::IGLoader.new(config_keeper.ig_deps_path).load
      if ig_resources.cs_resources.present?
        return InfernoSuiteGenerator::Generator::IGMetadataExtractor.new(ig_resources).extract
      end

      build_new_metadata_without_capability_statement(ig_resources, config_keeper)
    end

    def build_new_metadata_without_capability_statement(ig_resources, config_keeper)
      ig_metadata = build_ig_metadata_base(config_keeper)
      groups = synthetic_profile_groups(ig_resources, ig_metadata)
      ig_metadata.groups = groups
      ig_metadata.postprocess_groups(ig_resources)
      ig_metadata
    end

    def build_ig_metadata_base(config_keeper)
      ig_metadata = InfernoSuiteGenerator::Generator::IGMetadata.new
      ig_metadata.ig_version = "v#{config_keeper.version}"
      ig_metadata.ig_id = config_keeper.id
      ig_metadata.ig_title = config_keeper.title
      ig_metadata.ig_module_name_prefix = config_keeper.module_name_prefix
      ig_metadata.ig_test_id_prefix = config_keeper.test_id_prefix
      ig_metadata
    end

    def synthetic_profile_groups(ig_resources, ig_metadata)
      au_ps_profiles(ig_resources).filter_map do |profile|
        capability = synthetic_resource_capability(profile)
        InfernoSuiteGenerator::Generator::GroupMetadataExtractor.new(
          capability, profile.url, ig_metadata, ig_resources
        ).group_metadata
      rescue StandardError => e
        warn "Skipping profile #{profile.url}: #{e.message}"
        nil
      end
    end

    def au_ps_profiles(ig_resources)
      ig_resources
        .get_resources_by_type('StructureDefinition')
        .select { |profile| profile.url.to_s.start_with?('http://hl7.org.au/fhir/ps/StructureDefinition/') }
        .reject { |profile| profile.type == 'Extension' || profile.snapshot.blank? }
    end

    def synthetic_resource_capability(profile)
      SyntheticCapability.new(
        type: profile.type,
        interaction: [],
        operation: [],
        searchParam: [],
        searchInclude: [],
        searchRevInclude: [],
        extension: []
      )
    end

    # Registers a config_keeper for the given IG version/archive, always overwriting any
    # previously registered one. This is per-archive (not memoized) so that generating
    # multiple IG versions picks up the right ig.version/ig.package_archive_path each time
    # instead of the static values in inferno_suite_generator.config.json.
    #
    # @param ig_version [String] full IG version (e.g. "1.0.0-preview")
    # @param ig_path [String] path to the IG package archive being processed
    def register_inferno_suite_generator_config(ig_version, ig_path)
      base_config_path = inferno_suite_generator_config_path
      return unless base_config_path

      override_path = write_ig_config_override(ig_version, ig_path)
      keeper = InfernoSuiteGenerator::Generator::GeneratorConfigKeeper.new([base_config_path, override_path])
      Registry.register(:config_keeper, keeper)
    rescue StandardError => e
      warn "Failed to register inferno_suite_generator config: #{e.message}"
      nil
    end

    def inferno_suite_generator_config_path
      config_paths = [
        File.expand_path('../../../inferno_suite_generator.config.json', __dir__),
        File.expand_path('../../../../inferno_suite_generator.config.json', __dir__)
      ]
      config_paths.find { |path| File.exist?(path) }
    end

    # Writes a small override config (deep-merged over inferno_suite_generator.config.json)
    # pinning ig.version/ig.package_archive_path to the archive currently being processed.
    #
    # @return [String] path to the written override config file
    def write_ig_config_override(ig_version, ig_path)
      override = { 'ig' => { 'version' => ig_version.to_s, 'package_archive_path' => ig_path.to_s } }
      override_path = File.expand_path(File.join('tmp',
                                                 "ig_config_override_#{Naming.reformatted_version(ig_version)}.json"))
      FileUtils.mkdir_p(File.dirname(override_path))
      File.write(override_path, JSON.dump(override))
      override_path
    end

    def merge_metadata_values(old_value, new_value)
      return old_value if new_value.nil?
      return new_value if old_value.nil?

      if old_value.is_a?(Hash) && new_value.is_a?(Hash)
        merge_metadata_hashes(old_value, new_value)
      elsif old_value.is_a?(Array) && new_value.is_a?(Array)
        merge_metadata_arrays(old_value, new_value)
      else
        old_value
      end
    end

    def merge_metadata_hashes(old_hash, new_hash)
      (old_hash.keys | new_hash.keys).to_h do |key|
        [key, merge_metadata_values(old_hash[key], new_hash[key])]
      end
    end

    def merge_metadata_arrays(old_array, new_array)
      old_array + new_array.reject { |item| old_array.include?(item) }
    end
  end
end
