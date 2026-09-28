#!/usr/bin/env ruby
# frozen_string_literal: true

# Checks the FHIR package registries for an AU PS release newer than the newest released
# version the kit carries. A released IG version never changes, so a new release is added
# alongside the existing ones rather than replacing them: the script writes the new version's
# generator config, scaffolds its suite class, registers it in lib/au_ps_inferno.rb and
# generates its metadata. The existing suites, their ids and their sessions are untouched.
#
# Keys in NON_RELEASE_KEYS name versions that are not releases (a moving CI build, for one)
# and are never treated as the newest release.

require 'json'
require 'rubygems'
require_relative 'fetch_latest_ig_package'
require_relative '../lib/au_ps_inferno/suite_version'

CONFIG_PREFIX = 'config.'
ENTRY_POINT_PATH = File.join(ROOT_DIR, 'lib', 'au_ps_inferno.rb')
NON_RELEASE_KEYS = %w[ci-build].freeze

def config_path_for(version_key)
  File.join(ROOT_DIR, "#{CONFIG_PREFIX}#{version_key}.json")
end

def released_version_keys
  Dir.glob(File.join(ROOT_DIR, "#{CONFIG_PREFIX}*.json"))
     .map { |path| File.basename(path, '.json').delete_prefix(CONFIG_PREFIX) }
     .reject { |key| NON_RELEASE_KEYS.include?(key) }
end

def newest_released_key
  released_version_keys.max_by { |key| Gem::Version.new(key) }
end

def suite_file_for(new_version)
  "lib/au_ps_inferno/suite/#{AUPSTestKit::SuiteVersion.suite_id_for(new_version)}.rb"
end

def write_config_for_new_version!(base_config, old_version:, new_version:, new_archive_path:)
  config = JSON.parse(JSON.generate(base_config))
  config['kit']['suite_file'] = suite_file_for(new_version)
  ig = config['ig']
  ig['version'] = new_version
  ig['package_archive_path'] = new_archive_path
  cs_url = ig['cs_version_specific_url']
  ig['cs_version_specific_url'] = cs_url.sub(old_version, new_version) if cs_url
  File.write(config_path_for(new_version), "#{JSON.pretty_generate(config)}\n")
end

def suite_class_source(new_version) # rubocop:disable Metrics/MethodLength
  suite_id = AUPSTestKit::SuiteVersion.suite_id_for(new_version)
  class_name = "AUPS#{suite_id.to_s.delete_prefix('au_ps_').split('_').map(&:capitalize).join}Suite"
  <<~RUBY
    # frozen_string_literal: true

    require_relative 'au_ps_suite_definition'

    module AUPSTestKit
      # Test suite for the AU PS (Australian Primary Care and Shared Health) Implementation Guide #{new_version}.
      class #{class_name} < Inferno::TestSuite
        IG_VERSION = '#{new_version}'
        SUITE_VERSION = SuiteVersion.new(key: '#{new_version}', ig_version: IG_VERSION)

        extend AUPSSuiteDefinition

        define_au_ps_suite(
          SUITE_VERSION,
          title: "AU PS \#{IG_VERSION} Test Suite",
          description: 'Validates AU PS (Australian Primary Care and Shared Health) bundles, ' \\
                       'compositions, sections, and server CapabilityStatement support for the ' \\
                       "\#{IG_VERSION} implementation guide."
        )
      end
    end
  RUBY
end

# Adds the new suite's require after the last released suite's require.
def register_suite!(new_version)
  require_line = "require_relative 'au_ps_inferno/suite/#{AUPSTestKit::SuiteVersion.suite_id_for(new_version)}'\n"
  lines = File.readlines(ENTRY_POINT_PATH)
  return if lines.include?(require_line)

  last_released = lines.rindex { |line| line.start_with?("require_relative 'au_ps_inferno/suite/au_ps_v") }
  raise "No released suite require found in #{ENTRY_POINT_PATH}" unless last_released

  lines.insert(last_released + 1, require_line)
  File.write(ENTRY_POINT_PATH, lines.join)
end

def scaffold_new_version!(base_config, old_version:, new_version:, new_archive_path:)
  write_config_for_new_version!(base_config, old_version:, new_version:, new_archive_path:)
  File.write(File.join(ROOT_DIR, suite_file_for(new_version)), suite_class_source(new_version))
  register_suite!(new_version)
end

# A version counts as carried when the kit already has a config for it. Comparing by presence
# rather than by version order means a release that sorts below a carried ballot (1.0.1 after
# 1.1.0-ballot) is still added.
def carried?(version)
  File.exist?(config_path_for(version))
end

# fetch_latest_ig_package downloads before the version is known; remove the archive again
# when that version is not added, so an unchanged run leaves the tree clean.
def discard_download!(path, existed_before:)
  File.delete(path) if !existed_before && File.exist?(path)
end

def write_github_output(old_version:, new_version:)
  output_path = ENV.fetch('GITHUB_OUTPUT', nil)
  return unless output_path

  File.open(output_path, 'a') do |file|
    file.puts "old_version=#{old_version}"
    file.puts "new_version=#{new_version}"
  end
end

if $PROGRAM_NAME == __FILE__
  old_version = newest_released_key
  abort "No released AU PS version config (#{CONFIG_PREFIX}<version>.json) found in #{ROOT_DIR}" unless old_version
  base_config = JSON.parse(File.read(config_path_for(old_version)))

  archives_before = Dir.glob(File.join(DEFAULT_DESTINATION, '*'))
  result = fetch_latest_ig_package
  case result.status
  when :not_found
    warn "#{DEFAULT_PACKAGE_NAME} not found on any of: #{DEFAULT_REGISTRIES.join(', ')}"
    exit 1
  when :error
    warn "Failed to fetch #{DEFAULT_PACKAGE_NAME}: #{result.error}"
    exit 1
  end

  new_version = result.package.version

  if carried?(new_version)
    discard_download!(result.path, existed_before: archives_before.include?(result.path))
    puts "Already carried: #{DEFAULT_PACKAGE_NAME}@#{new_version}"
    exit 0
  end

  new_archive_path = result.path.delete_prefix("#{ROOT_DIR}/")
  scaffold_new_version!(base_config, old_version:, new_version:, new_archive_path:)

  Dir.chdir(ROOT_DIR) do
    system('bundle', 'exec', 'rake', "au_ps:generate[#{new_version}]", exception: true)
  end

  puts "Added AU PS #{new_version} suite alongside #{old_version}"
  write_github_output(old_version: old_version, new_version: new_version)
end
