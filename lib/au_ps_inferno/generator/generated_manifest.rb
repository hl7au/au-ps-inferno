# frozen_string_literal: true

require 'yaml'
require 'digest'
require 'fileutils'

class Generator
  # Reads/writes lib/au_ps_inferno/igs/generated/<archive>.yaml fragment files, recording which
  # IG archives have already been generated (with their checksum and resulting IG version), so
  # CI/Rake can tell whether an archive under lib/au_ps_inferno/igs/ is new or has changed.
  #
  # Each archive gets its own fragment file (rather than one shared manifest) so that concurrent
  # `generate-suite` CI runs for different archives never write to the same file and race.
  class GeneratedManifest
    def initialize(igs_dir)
      @igs_dir = igs_dir
      @generated_dir = File.join(igs_dir, 'generated')
    end

    def entries
      Dir.glob(File.join(@generated_dir, '*.yaml')).map { |path| YAML.safe_load_file(path) }
    end

    def changed?(archive_path)
      entry = YAML.safe_load_file(fragment_path(archive_path)) if File.exist?(fragment_path(archive_path))
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
      entry = {
        'archive' => File.basename(archive_path),
        'sha256' => checksum(archive_path),
        'ig_version' => ig_version,
        'generated_at' => Time.now.utc.strftime('%Y-%m-%d')
      }
      FileUtils.mkdir_p(@generated_dir)
      File.write(fragment_path(archive_path), YAML.dump(entry))
    end

    private

    def fragment_path(archive_path)
      File.join(@generated_dir, "#{File.basename(archive_path)}.yaml")
    end
  end
end
