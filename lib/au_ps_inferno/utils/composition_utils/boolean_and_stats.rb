# frozen_string_literal: true

require 'cgi'

# Bundle-level booleans and per-path statistics lines for CompositionUtils.
module CompositionUtilsBooleanAndStats
  FHIRPATH_LAB_URL = ENV.fetch('FHIRPATH_LAB_URL', 'https://fhirpath-lab.com/FhirPath')

  def boolean_to_existent_string(boolean_value, optional: false)
    missing_icon = optional ? '⚠️' : '❌'
    boolean_value ? '✅ Populated' : "#{missing_icon} Missing"
  end

  def fhirpath_lab_link(expression, url = fhirpath_lab_resource_url, full_expression: expression)
    return expression if url.blank?

    query = "expression=#{CGI.escape(full_expression)}" \
            "&engine=fhirpath.js&resource=#{CGI.escape(url)}"
    "[#{expression}](#{FHIRPATH_LAB_URL}?#{query})"
  end

  def fhirpath_lab_resource_url
    scratch_bundle_url
  end

  def all_entries_have_full_url_info?
    entry_full_url_count = resolve_path_with_dar(scratch_bundle, 'entry.fullUrl').length
    entries_count = resolve_path_with_dar(scratch_bundle, 'entry').length

    entry_full_url_count == entries_count
  end

  def timestamp_info?
    resolve_path_with_dar(scratch_bundle, 'timestamp').first.present?
  end

  def type_info?
    resolve_path_with_dar(scratch_bundle, 'type').first.present?
  end

  def identifier_info?
    resolve_path_with_dar(scratch_bundle, 'identifier').first.present?
  end
end
