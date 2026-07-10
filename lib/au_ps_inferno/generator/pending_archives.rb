# frozen_string_literal: true

require_relative 'generated_manifest'

class Generator
  # Lists lib/au_ps_inferno/igs/*.tgz archives that are new or whose content changed since the
  # last recorded generation (per lib/au_ps_inferno/igs/generated.yaml). Used by `rake
  # generator:pending` and CI to decide whether there is anything to generate a suite for.
  class PendingArchives
    def initialize(igs_dir = default_igs_dir)
      @igs_dir = igs_dir
      @manifest = GeneratedManifest.new(igs_dir)
    end

    def list
      Dir.glob(File.join(@igs_dir, '*.tgz')).select { |archive| @manifest.changed?(archive) }
    end

    private

    def default_igs_dir
      File.join('lib', 'au_ps_inferno', 'igs')
    end
  end
end
