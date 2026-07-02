# frozen_string_literal: true

require 'fileutils'
require_relative 'naming'

class Generator
  # Stamps the composition/bundle validation group families (currently hand-authored,
  # not yet metadata-driven) into a version-specific output folder, appending the IG
  # version suffix to every class name and Inferno id so multiple IG versions can be
  # loaded in the same process without collisions.
  #
  # The families themselves are structurally identical sets of tests (bundle
  # validation, must-support conformance, composition sections, subject/author/
  # custodian/attester) applied to different bundle sources. Their canonical,
  # unsuffixed content lives under generator/templates/hand_authored_groups/<family>/
  # and is copied + rewritten per IG version rather than hand-duplicated per version.
  #
  # @see docs/plans/ig-version-specific-suites.md Phase 3
  class HandAuthoredGroupsGenerator
    include Naming

    FAMILIES = %w[
      au_ps_bundle_instance
      au_ps_retrieve_cs_group
      retrieve_au_ps_bundle_validation_tests
      generate_au_ps_using_ips_summary_validation_tests
    ].freeze

    TEMPLATES_DIR = File.expand_path(File.join(__dir__, 'templates', 'hand_authored_groups'))

    ID_DECLARATION_PATTERN = /((?:^\s*id|group from:|test from:)\s+):([a-z0-9_]+)/
    CLASS_DECLARATION_PATTERN = /^(\s*class\s+)([A-Za-z0-9_]+)(\s*<.*)$/

    # @param suite_version [String] full IG version (e.g. "1.0.0-preview"), used to build the output path
    # @param version_suffix [String] compact version suffix (e.g. "100preview")
    def initialize(suite_version, version_suffix)
      @suite_version = suite_version.to_s
      @version_suffix = version_suffix.to_s
      @output_dir = File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version))
    end

    # Stamps every family into the version output folder.
    #
    # @return [Array<Hash>] one entry per family, each with:
    #   :require_path (relative to the generated suite file) and :group_id (Symbol)
    def generate
      FAMILIES.map { |family| stamp_family(family) }
    end

    private

    def stamp_family(family)
      source_dir = File.join(TEMPLATES_DIR, family)
      target_dir = File.join(@output_dir, family)

      Dir.glob(File.join(source_dir, '**', '*.rb')).each do |source_file|
        stamp_file(source_file, source_dir, target_dir)
      end

      {
        require_path: File.join(family, family),
        group_id: extract_root_id(File.join(target_dir, "#{family}.rb"))
      }
    end

    def stamp_file(source_file, source_dir, target_dir)
      relative_path = source_file.delete_prefix("#{source_dir}/")
      target_file = File.join(target_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(target_file))
      File.write(target_file, stamp_content(File.read(source_file)))
    end

    def stamp_content(content)
      stamped = content.gsub(CLASS_DECLARATION_PATTERN) do
        "#{Regexp.last_match(1)}#{versioned_class_name(Regexp.last_match(2), @version_suffix)}#{Regexp.last_match(3)}"
      end
      stamped.gsub(ID_DECLARATION_PATTERN) do
        "#{Regexp.last_match(1)}:#{versioned_id(Regexp.last_match(2), @version_suffix)}"
      end
    end

    def extract_root_id(root_file)
      match = File.read(root_file).match(/^\s*id\s+:([a-z0-9_]+)/)
      match && match[1].to_sym
    end
  end
end
