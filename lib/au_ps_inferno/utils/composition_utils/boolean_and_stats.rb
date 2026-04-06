# frozen_string_literal: true

# Bundle-level booleans and per-path statistics lines for CompositionUtils.
module CompositionUtilsBooleanAndStats
  def boolean_to_existent_string(boolean_value)
    boolean_value ? '✅ Populated' : '❌ Missing'
  end

  def execute_statistics(resource, path_expression, humanized_name)
    data_value = resolve_path_with_dar(resource, path_expression).first.present?
    boolean_value = boolean_to_existent_string(data_value)
    "**#{humanized_name}**: #{boolean_value}"
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

  def check_section_element_completeness(path_expression)
    sections_count = resolve_path_with_dar(composition_resource, path_expression).length
    selected_by_expression_count = resolve_path_with_dar(composition_resource, path_expression).length

    boolean_to_existent_string(sections_count == selected_by_expression_count)
  end
end
