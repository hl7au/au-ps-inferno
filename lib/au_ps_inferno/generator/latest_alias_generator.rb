# frozen_string_literal: true

require_relative 'test_file_generator'

class Generator
  # Regenerates lib/au_ps_inferno/suite/suite.rb as a thin alias over whichever generated
  # IG version is "latest" (highest by Gem::Version; a plain final release like "1.0.0"
  # outranks prereleases such as "1.0.0-preview"/"1.0.0-ballot", matching semver rules).
  # Between two prereleases the tie-break is alphabetical on the prerelease tag, which is
  # arbitrary but deterministic — there is no universal ordering between e.g. "-preview"
  # and "-ballot" drafts of the same IG.
  #
  # This keeps a stable, version-agnostic :suite id available for any tooling/URLs that
  # depend on it, without duplicating generated content: it requires the winning version's
  # suite file and re-declares its already-registered group ids under the bare suite class.
  #
  # Run after generating every IG version (see Rakefile generator:generate).
  class LatestAliasGenerator
    OUTPUT_DIR = File.expand_path(File.join('lib', 'au_ps_inferno', 'suite'))

    class << self
      def generate
        new.generate
      end
    end

    def generate
      version_dir, suite_file = latest_suite_file
      return if suite_file.nil?

      TestFileGenerator.new(
        template_file_path: 'suite_alias.rb.erb',
        output_file_path: 'suite.rb',
        output_base: OUTPUT_DIR,
        attributes: alias_attributes(version_dir, suite_file)
      ).generate
    end

    private

    def alias_attributes(version_dir, suite_file)
      content = File.read(suite_file)
      {
        suite_require_path: File.join('..', version_dir, File.basename(suite_file, '.rb')),
        suite_version: content[/title 'AU PS (\S+) Test Suite'/, 1],
        groups: content.scan(/group from: :(\S+)/).flatten
      }
    end

    # @return [Array(String, String)] [version folder name, absolute path to its *_suite.rb],
    #   or [nil, nil] when no version has been generated yet
    def latest_suite_file
      candidates = Dir.glob(File.expand_path(File.join('lib', 'au_ps_inferno', '*', '*_suite.rb')))
      return [nil, nil] if candidates.empty?

      best = candidates.max_by { |path| version_sort_key(File.basename(File.dirname(path))) }
      [File.basename(File.dirname(best)), best]
    end

    def version_sort_key(version_string)
      Gem::Version.new(version_string)
    rescue ArgumentError
      version_string
    end
  end
end
