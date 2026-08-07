# frozen_string_literal: true

class Generator
  # Module for building group-based metadata
  module GeneratorGroupBasedMetadataModule
    private

    def build_new_metadata
      config_keeper = Registry.get(:config_keeper)
      return nil unless config_keeper

      InfernoSuiteGenerator::Generator::IGMetadataExtractor.new(@ig_resources).extract
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
  end
end
