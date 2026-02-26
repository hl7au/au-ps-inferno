# frozen_string_literal: true

class Generator
  # Derives the suite version folder name from an IG package path.
  # Example: "lib/au_ps_inferno/igs/1.0.0-preview.tgz" -> "1.0.0-preview"
  #
  # @param ig_path [String] Path to the IG package (e.g. .tgz or .tar.gz)
  # @return [String] Version string for use in lib/au_ps_inferno/{suite_version}/ paths
  def self.suite_version_from_ig_path(ig_path)
    return '' if ig_path.nil? || ig_path.to_s.strip.empty?

    base = File.basename(ig_path.to_s.strip)
    base.chomp('.tgz').chomp('.tar.gz').chomp('.tar')
  end

  # Converts a semantic version string into a short suffix for class names and ids.
  # Example: "1.0.0-preview" -> "100preview", "0.5.0-preview" -> "050preview"
  #
  # @param version [String] Version string (e.g. from IG path basename "1.0.0-preview.tgz")
  # @return [String] Alphanumeric suffix suitable for Ruby class names and symbols
  def self.version_suffix(version)
    return '' if version.nil? || version.to_s.strip.empty?

    base = version.to_s.strip
    base = File.basename(base, '.tgz')
    base = File.basename(base, '.tar.gz')
    base = File.basename(base, '.tar')

    numeric_part = base.split('-').first || ''
    prerelease_part = base.include?('-') ? base.split('-', 2).last : ''

    numeric_suffix = numeric_part.gsub(/\D/, '')
    prerelease_suffix = prerelease_part.gsub(/[^a-zA-Z0-9]/, '')

    [numeric_suffix, prerelease_suffix].reject(&:empty?).join
  end
end
