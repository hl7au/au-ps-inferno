#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative 'fetch_latest_ig_package'

CONFIG_PATH = File.join(ROOT_DIR, 'inferno_suite_generator.config.json')

def update_config_for_new_version!(config, old_version:, new_version:, new_archive_path:)
  config['ig']['version'] = new_version
  config['ig']['package_archive_path'] = new_archive_path
  cs_url = config['ig']['cs_version_specific_url']
  config['ig']['cs_version_specific_url'] = cs_url.sub(old_version, new_version) if cs_url
  File.write(CONFIG_PATH, "#{JSON.pretty_generate(config)}\n")
end

def remove_stale_archive!(path)
  return unless path && File.exist?(path)

  File.delete(path)
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
  config = JSON.parse(File.read(CONFIG_PATH))
  old_version = config.dig('ig', 'version')
  old_archive_path = config.dig('ig', 'package_archive_path')

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

  if new_version == old_version
    puts "Already up to date: #{DEFAULT_PACKAGE_NAME}@#{old_version}"
    exit 0
  end

  new_archive_path = result.path.delete_prefix("#{ROOT_DIR}/")
  update_config_for_new_version!(config, old_version: old_version, new_version: new_version,
                                         new_archive_path: new_archive_path)
  remove_stale_archive!(old_archive_path && File.join(ROOT_DIR, old_archive_path))

  Dir.chdir(ROOT_DIR) do
    system('bundle', 'exec', 'rake', 'generator:generate', exception: true)
  end

  puts "Updated AU PS suite: #{old_version} -> #{new_version}"
  write_github_output(old_version: old_version, new_version: new_version)
end
