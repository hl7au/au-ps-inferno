# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open-uri'
require 'rubygems/package'
require 'zlib'

module AUPSTestKit
  # Keeps the ci-build suite in step with the AU PS CI build published on build.fhir.org
  # (https://build.fhir.org/ig/hl7au/au-fhir-ps/).
  #
  # build.fhir.org publishes package.manifest.json next to package.tgz, and its +date+ changes
  # on every CI build. config.ci-build.json records the date of the package the ci-build
  # suite was generated from (+ci_build.package_date+). When the published date differs, the
  # package is downloaded to lib/au_ps_inferno/igs/ci-build.tgz (gitignored), its own version
  # and date are recorded, and only the ci-build version is regenerated. The released suites
  # are never touched. The rake tasks in ci_build.rake drive this, matching the AU Core kit's
  # au_core:ci_build tasks.
  class CIBuild
    CONFIG_FILE = 'config.ci-build.json'
    VERSION_KEY = 'ci-build'
    CI_BUILD_VERSION_SUFFIX = '-ci-build'

    class Error < StandardError; end

    # Hands values to later steps of a GitHub Actions job; a no-op outside Actions.
    def self.write_github_output(values)
      return unless ENV['GITHUB_OUTPUT']

      File.open(ENV.fetch('GITHUB_OUTPUT'), 'a') do |file|
        values.each { |key, value| file.puts("#{key}=#{value}") }
      end
    end

    attr_reader :root

    def initialize(root: File.expand_path('..', __dir__))
      @root = root
    end

    def config
      JSON.parse(File.read(config_path))
    end

    def version
      config.dig('ig', 'version')
    end

    def recorded_date
      config.dig('ci_build', 'package_date')
    end

    def package_path
      File.join(root, config.dig('ig', 'package_archive_path'))
    end

    # @return [Hash] the published package.manifest.json
    def published_manifest
      JSON.parse(fetch(config.dig('ci_build', 'manifest_url')))
    end

    def changed?
      published_manifest.fetch('date') != recorded_date
    end

    # Downloads package.tgz and records the version and date from the package's own
    # package.json, so a CI build that lands between the manifest request and the download
    # cannot leave the config describing a different package.
    #
    # @return [Hash] the downloaded package's package.json
    def download
      FileUtils.mkdir_p(File.dirname(package_path))
      File.binwrite(package_path, fetch(config.dig('ci_build', 'package_url')))
      package = package_json(package_path)
      ensure_ci_build_version!(package['version'])
      record(package)
      package
    end

    # Regenerates the ci-build suite when the CI build changed, or always with +force+. The
    # block runs the generator. A failed refresh puts the config back as it was.
    #
    # @return [Boolean] whether the suite was regenerated
    def refresh(force: false)
      return false unless force || changed?

      original_config = File.read(config_path)
      begin
        download
        yield
      rescue StandardError
        File.write(config_path, original_config)
        raise
      end
      true
    end

    # Refuses to generate from a local package other than the one the config records, so a
    # stale download cannot silently regenerate old metadata under a newer date.
    def ensure_package!
      unless File.exist?(package_path)
        raise Error, "#{package_path} is missing; run rake au_ps:ci_build:download first."
      end

      package = package_json(package_path)
      return if package['version'] == version && package['date'] == recorded_date

      raise Error, "#{package_path} holds #{package['version']} dated #{package['date']}, but #{CONFIG_FILE} " \
                   "records #{version} dated #{recorded_date}; run rake au_ps:ci_build:download."
    end

    private

    def config_path
      File.join(root, CONFIG_FILE)
    end

    def fetch(url)
      URI.parse(url).open(read_timeout: 120, &:read)
    end

    def ensure_ci_build_version!(candidate)
      return if candidate.to_s.end_with?(CI_BUILD_VERSION_SUFFIX)

      raise Error, "CI build version is #{candidate.inspect}; expected a version ending in #{CI_BUILD_VERSION_SUFFIX}."
    end

    def record(package)
      updated = config
      updated['ig']['version'] = package.fetch('version')
      updated['ci_build']['package_date'] = package.fetch('date')
      File.write(config_path, "#{JSON.pretty_generate(updated)}\n")
    end

    def package_json(tgz)
      Zlib::GzipReader.open(tgz) do |gzip|
        Gem::Package::TarReader.new(gzip) do |tar|
          entry = tar.find { |candidate| candidate.full_name == 'package/package.json' }
          raise Error, 'package/package.json not found in the CI build package.' unless entry

          return JSON.parse(entry.read)
        end
      end
    end
  end
end
