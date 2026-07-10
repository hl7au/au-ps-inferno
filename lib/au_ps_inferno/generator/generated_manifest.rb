# frozen_string_literal: true

require 'yaml'
require 'digest'
require 'fileutils'

class Generator
  # Reads/writes lib/au_ps_inferno/igs/generated.yaml, the manifest of which IG archives have
  # already been generated (with their checksum and resulting IG version), so CI/Rake can tell
  # whether an archive under lib/au_ps_inferno/igs/ is new or has changed.
  class GeneratedManifest
    def initialize(igs_dir)
      @igs_dir = igs_dir
      @manifest_path = File.join(igs_dir, 'generated.yaml')
    end

    def entries
      return [] unless File.exist?(@manifest_path)

      YAML.safe_load_file(@manifest_path) || []
    end

    def changed?(archive_path)
      entry = entries.find { |e| e['archive'] == File.basename(archive_path) }
      entry.nil? || entry['sha256'] != checksum(archive_path)
    end

    def checksum(archive_path)
      Digest::SHA256.file(archive_path).hexdigest
    end

    # Records (or updates) this archive's entry after a successful generation run.
    #
    # @param archive_path [String] path to the .tgz archive that was generated
    # @param ig_version [String] IG version the archive generated (from package.json)
    # @return [void]
    def record(archive_path, ig_version)
      archive_name = File.basename(archive_path)
      updated = entries.reject { |e| e['archive'] == archive_name }
      updated << {
        'archive' => archive_name,
        'sha256' => checksum(archive_path),
        'ig_version' => ig_version,
        'generated_at' => Time.now.utc.strftime('%Y-%m-%d')
      }
      FileUtils.mkdir_p(@igs_dir)
      File.write(@manifest_path, YAML.dump(updated.sort_by { |e| e['archive'] }))
    end
  end
end
