# frozen_string_literal: true

module AUPSTestKit
  # One AU PS IG version the kit carries a suite for.
  #
  # +key+ names the version's generator config (+config.<key>.json+)
  # and its generated metadata folder (+lib/au_ps_inferno/generated/<key>/+). For a released IG the key
  # is the IG version itself; a moving target such as the CI build uses a stable key
  # (+ci-build+) so a new CI package version regenerates in place.
  #
  # +ig_version+ is the package version the suite is generated from. It also names the
  # suite id (see {.suite_id_for}) and versions the AU PS profile canonicals the tests
  # validate against.
  #
  # +validator_package+ is the package reference handed to the HL7 validator, always a
  # package id (+hl7.fhir.au.ps#<version>+), never a file path.
  SuiteVersion = Data.define(:key, :ig_version, :validator_package) do
    # @param key [String]
    # @param ig_version [String]
    # @param validator_package [String, nil] defaults to +hl7.fhir.au.ps#<ig_version>+
    def initialize(key:, ig_version:, validator_package: nil)
      super(key:, ig_version:, validator_package: validator_package || "#{SuiteVersion::PACKAGE_ID}##{ig_version}")
    end

    # @return [Symbol] e.g. +:au_ps_v100+ for 1.0.0, +:au_ps_v101_ci_build+ for 1.0.1-ci-build
    def suite_id
      SuiteVersion.suite_id_for(ig_version)
    end

    # @return [String] absolute path of the folder holding this version's generated metadata
    def metadata_dir
      SuiteVersion.metadata_dir_for(key)
    end

    # @return [String] absolute path of this version's metadata.yaml
    def metadata_path
      File.join(metadata_dir, 'metadata.yaml')
    end

    # Options every runnable in this version's suite receives through Inferno's +config+,
    # so shared test classes resolve the metadata and profile version of the suite that
    # includes them rather than a single global.
    #
    # @return [Hash]
    def runnable_options
      { au_ps_ig_version: ig_version, au_ps_metadata_path: metadata_path }
    end
  end

  # Naming rules shared by every suite version.
  class SuiteVersion
    PACKAGE_ID = 'hl7.fhir.au.ps'
    SUITE_ID_PREFIX = 'au_ps_v'
    VERSION_PATTERN = /\A(?<release>\d+(?:\.\d+)*)(?:-(?<label>[0-9A-Za-z.-]+))?\z/
    SUITE_ID_PATTERN = /\A[a-z][a-z0-9_]*\z/

    # Derives the suite id from an IG package version: the release digits are joined and
    # any pre-release label is appended in snake case, so +1.0.0+ becomes +au_ps_v100+ and
    # +1.0.1-ci-build+ becomes +au_ps_v101_ci_build+.
    #
    # @param ig_version [String]
    # @return [Symbol]
    def self.suite_id_for(ig_version)
      match = VERSION_PATTERN.match(ig_version.to_s)
      raise ArgumentError, "Not an IG package version: #{ig_version.inspect}" unless match

      label = match[:label]&.downcase&.gsub(/[^a-z0-9]+/, '_')
      :"#{SUITE_ID_PREFIX}#{match[:release].delete('.')}#{"_#{label}" if label}"
    end

    # @param key [String]
    # @return [String]
    def self.metadata_dir_for(key)
      File.expand_path(File.join('generated', key), __dir__)
    end
  end
end
