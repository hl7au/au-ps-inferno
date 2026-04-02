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
        remove_special_characters(s.include?(' ') ? s.tr(' ', '_') : s).downcase
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
  end
end
