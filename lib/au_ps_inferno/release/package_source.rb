# frozen_string_literal: true

require 'json'
require 'fhir_packages_manager'

module Release
  # Wraps FhirPackagesManager::Manager to download every published, non-ignored
  # version of the configured IG package
  class PackageSource
    Downloaded = Struct.new(:version, :path, keyword_init: true)

    DEFAULT_CONFIG_PATH = 'release.config.json'

    def initialize(config_path: DEFAULT_CONFIG_PATH, config: nil)
      @config = config || JSON.parse(File.read(config_path))
    end

    def sync_all
      results = manager.sync(@config.fetch('ig_id'))
      results
        .select { |result| result.downloaded? || result.skipped? }
        .map { |result| Downloaded.new(version: result.package.version, path: result.path) }
        .sort_by(&:version)
    end

    private

    def manager
      FhirPackagesManager::Manager.new(
        registries: @config.fetch('registries'),
        destination: @config.fetch('destination'),
        ignore_list: ignore_list
      )
    end

    def ignore_list
      path = @config['ignore_list']
      return nil unless path && File.exist?(path)

      FhirPackagesManager::IgnoreList.load(path)
    end
  end
end
