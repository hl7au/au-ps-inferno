# frozen_string_literal: true

module AUPSTestKit
  # One AU PS IG version the kit carries a suite for.
  #
  # +key+ names the version's generator config (+config.<key>.json+)
  # and its generated metadata folder (+lib/au_ps_inferno/generated/<key>/+). For a released IG the key
  # is the IG version itself; a moving target such as the CI build uses a stable key
  # (+ci-build+) so a new CI package version regenerates in place.
  #
  # +ig_version+ is the package version the suite is generated from. It versions the AU PS
  # profile canonicals the tests validate against and, unless +fixed_suite_id+ is given,
  # names the suite id (see {.suite_id_for}).
  #
  # +validator_package+ is the package reference handed to the HL7 validator, always a
  # package id (+hl7.fhir.au.ps#<version>+), never a file path.
  #
  # +fixed_suite_id+ pins the suite id for a version whose package version moves (the CI
  # build), so its sessions and the places that list it by id survive a version bump.
  SuiteVersion = Data.define(:key, :ig_version, :validator_package, :fixed_suite_id) do
    # @param key [String]
    # @param ig_version [String]
    # @param validator_package [String, nil] defaults to +hl7.fhir.au.ps#<ig_version>+
    # @param suite_id [Symbol, String, nil] a fixed suite id; derived from +ig_version+ when nil
    def initialize(key:, ig_version:, validator_package: nil, suite_id: nil, fixed_suite_id: suite_id)
      if fixed_suite_id && !SuiteVersion::SUITE_ID_PATTERN.match?(fixed_suite_id.to_s)
        raise ArgumentError, "Not a valid suite id: #{fixed_suite_id.inspect}"
      end

      super(key:, ig_version:, validator_package: validator_package || "#{SuiteVersion::PACKAGE_ID}##{ig_version}",
            fixed_suite_id: fixed_suite_id&.to_sym)
    end

    # @return [Symbol] the fixed suite id, or one derived from the IG version: +:au_ps_v100+
    #   for 1.0.0
    def suite_id
      fixed_suite_id || SuiteVersion.suite_id_for(ig_version)
    end

    # @return [String] absolute path of the folder holding this version's generated metadata
    def metadata_dir
      SuiteVersion.metadata_dir_for(key)
    end

    # @return [String] absolute path of this version's metadata.yaml
    def metadata_path
      File.join(metadata_dir, 'metadata.yaml')
    end

    # The version AU PS profile canonicals are pinned to (+au-ps-bundle|1.0.0+), or nil for a
    # version whose validator package floats (+#current+). A floating package can move to a new
    # version before the suite is regenerated, and a pinned canonical would then name a profile
    # version the validator no longer has, so those suites validate against the unversioned
    # canonical and take whatever version the validator loaded.
    #
    # @return [String, nil]
    def profile_version
      ig_version unless validator_package.end_with?('#current')
    end

    # Options every runnable in this version's suite receives through Inferno's +config+,
    # so shared test classes resolve the metadata and profile version of the suite that
    # includes them rather than a single global.
    #
    # @return [Hash]
    def runnable_options
      { au_ps_ig_version: ig_version, au_ps_profile_version: profile_version, au_ps_metadata_path: metadata_path }
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
