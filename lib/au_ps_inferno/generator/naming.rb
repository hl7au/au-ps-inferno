# frozen_string_literal: true

class Generator
  # Shared naming and ID helpers for suite, group, and test generation.
  # Use these when adding new groups or tests so IDs and class names stay consistent.
  module Naming
    class << self
      # @param string [String] space-separated or mixed-case string
      # @return [String] PascalCase (e.g. "Bundle Validation" => "BundleValidation")
      def camel_case(string)
        string.to_s.split.map(&:capitalize).join
      end

      # @param string [String]
      # @return [String] with $ . , ( ) - removed
      def remove_special_characters(string)
        special_characters = ['$', '.', ',', '(', ')', '-']
        string.to_s.gsub(Regexp.union(special_characters), '')
      end

      # @param string [String] human-readable name
      # @return [String] Ruby class name (PascalCase, no spaces/special chars)
      def build_class_name(string)
        camel_case(remove_special_characters(string)).gsub(' ', '')
      end

      # @param string [String, Symbol] human-readable name or test type id (symbol); Symbol converted via .to_s
      # @return [String] snake_case id (lowercase, underscores, no special chars)
      def build_id(string)
        s = string.to_s
        remove_special_characters(s.include?(' ') ? s.gsub(' ', '_') : s).downcase
      end

      # Reformats an IG version into the compact suffix used across versioned class
      # names and ids (e.g. "1.0.0-preview" => "100preview", "1.0.0-ballot" => "100ballot").
      # Strips '.' and '-' entirely (no underscore separator), matching the existing
      # convention already committed for the AU PS Retrieve CS Group classes.
      #
      # @param version [String] IG version string
      # @return [String] compact version suffix
      def reformatted_version(version)
        version.to_s.gsub(/[.\-]/, '')
      end

      # @param base [String] PascalCase base class name (e.g. "AUPSBundleInstance")
      # @param version_suffix [String] compact version suffix (e.g. "100preview")
      # @return [String] versioned PascalCase class name (e.g. "AUPSBundleInstance100preview")
      def versioned_class_name(base, version_suffix)
        version_suffix.to_s.empty? ? base : "#{base}#{version_suffix}"
      end

      # @param base [String, Symbol] snake_case base id (e.g. "au_ps_bundle_instance")
      # @param version_suffix [String] compact version suffix (e.g. "100preview")
      # @return [String] versioned snake_case id (e.g. "au_ps_bundle_instance_100preview")
      def versioned_id(base, version_suffix)
        version_suffix.to_s.empty? ? base.to_s : "#{base}_#{version_suffix}"
      end
    end

    # Instance methods for use with include Naming
    def camel_case(string)
      Naming.camel_case(string)
    end

    def remove_special_characters(string)
      Naming.remove_special_characters(string)
    end

    def build_class_name(string)
      Naming.build_class_name(string)
    end

    def build_id(string)
      Naming.build_id(string)
    end

    def reformatted_version(version)
      Naming.reformatted_version(version)
    end

    def versioned_class_name(base, version_suffix)
      Naming.versioned_class_name(base, version_suffix)
    end

    def versioned_id(base, version_suffix)
      Naming.versioned_id(base, version_suffix)
    end
  end
end
