# frozen_string_literal: true

class Generator
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
