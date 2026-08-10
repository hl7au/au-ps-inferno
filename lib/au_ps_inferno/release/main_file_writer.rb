# frozen_string_literal: true

module Release
  # Rewrites the auto-managed require block in lib/au_ps_inferno.rb.
  class MainFileWriter
    BEGIN_MARKER = '# BEGIN GENERATED RELEASE SUITES (auto-managed by `make new_release` -- do not edit by hand)'
    END_MARKER = '# END GENERATED RELEASE SUITES'

    DEFAULT_MAIN_FILE_PATH = 'lib/au_ps_inferno.rb'
    DEFAULT_GENERATED_ROOT = 'lib/au_ps_inferno/generated'

    def initialize(main_file_path: DEFAULT_MAIN_FILE_PATH, generated_root: DEFAULT_GENERATED_ROOT)
      @main_file_path = File.expand_path(main_file_path)
      @generated_root = File.expand_path(generated_root)
    end

    # @return [void]
    def write!
      File.write(@main_file_path, updated_contents)
    end

    private

    def updated_contents
      base = strip_existing_block(File.read(@main_file_path))
      "#{base.chomp}\n\n#{generated_block}\n"
    end

    def strip_existing_block(content)
      pattern = /\n*#{Regexp.escape(BEGIN_MARKER)}.*?#{Regexp.escape(END_MARKER)}\n?/m
      content.sub(pattern, '')
    end

    def generated_block
      lines = suite_require_lines
      return "#{BEGIN_MARKER}\n#{END_MARKER}" if lines.empty?

      "#{BEGIN_MARKER}\n#{lines.join("\n")}\n#{END_MARKER}"
    end

    def suite_require_lines
      generated_suite_versions.map { |version| "require_relative 'au_ps_inferno/generated/#{version}/suite'" }
    end

    def generated_suite_versions
      return [] unless Dir.exist?(@generated_root)

      Dir.children(@generated_root)
         .select { |name| File.exist?(File.join(@generated_root, name, 'suite.rb')) }
         .sort
    end
  end
end
