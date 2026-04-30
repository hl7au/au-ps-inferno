# frozen_string_literal: true

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

    def register_inferno_suite_generator_config
      return if Registry.get(:config_keeper)

      config_path = inferno_suite_generator_config_path
      return unless config_path

      keeper = InfernoSuiteGenerator::Generator::GeneratorConfigKeeper.new([config_path])
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
