# frozen_string_literal: true

require_relative '../bundle_decorator'

# Mandatory/optional MS element info blocks and composition resource accessor.
module CompositionUtilsMsElements
  MANDATORY_MS_SUB_ELEMENTS_TITLE =
    'Mandatory Must Support sub-elements of a complex element SHALL be correctly ' \
    'populated if a value is known'
  OPTIONAL_MS_SUB_ELEMENTS_TITLE =
    'Optional Must Support sub-elements of a complex element SHALL be correctly ' \
    'populated if a value is known'

  def composition_mandatory_ms_elements_info(groups)
    check_bundle_exists_in_scratch
    apply_ms_element_checks(groups)
    assert_mandatory_ms_populated(groups)
  end

  def apply_ms_element_checks(groups)
    check_mandatory_ms_elements(groups.fetch(:mandatory_ms_elements))
    check_optional_ms_elements(groups.fetch(:optional_ms_elements))
    check_mandatory_ms_sub_elements(groups.fetch(:mandatory_ms_sub_elements))
    check_optional_ms_sub_elements(groups.fetch(:optional_ms_sub_elements))
    check_mandatory_ms_slices(groups.fetch(:mandatory_ms_slices))
    check_optional_ms_slices(groups.fetch(:optional_ms_slices))
  end

  def assert_mandatory_ms_populated(groups)
    passed = all_elements_passed?(
      groups.fetch(:mandatory_ms_elements) + groups.fetch(:mandatory_ms_sub_elements)
    )
    assert passed, 'Mandatory Must Support elements are not populated'
  end

  def check_mandatory_ms_slices(mandatory_ms_slices)
    info_block('Mandatory Must Support slices SHALL be correctly populated if a value is known', mandatory_ms_slices)
  end

  def check_optional_ms_slices(optional_ms_slices)
    info_block('Optional Must Support slices SHALL be correctly populated if a value is known', optional_ms_slices)
  end

  def info_block(title, elements)
    info "**#{title}**:\n\n#{composition_mandatory_elements_info(elements)}"
  end

  def check_mandatory_ms_elements(mandatory_ms_elements)
    info_block('Mandatory Must Support elements are correctly populated',
               mandatory_ms_elements)
  end

  def check_optional_ms_elements(optional_ms_elements)
    info_block(
      'Optional Must Support elements are correctly populated', optional_ms_elements
    )
  end

  def check_mandatory_ms_sub_elements(mandatory_ms_sub_elements)
    info_block(MANDATORY_MS_SUB_ELEMENTS_TITLE, mandatory_ms_sub_elements)
  end

  def check_optional_ms_sub_elements(optional_ms_sub_elements)
    info_block(OPTIONAL_MS_SUB_ELEMENTS_TITLE, optional_ms_sub_elements)
  end

  # Generic: renders pass/fail for each element (or sub-element) in the given list.
  # Do not append section.title/section.text here; they are sub-elements and only
  # appear when in the metadata list (e.g. composition_mandatory_ms_sub_elements).
  def composition_mandatory_elements_info(mandatory_ms_elements)
    mandatory_ms_elements.map do |element|
      execute_statistics(composition_resource, element[:expression], element[:label])
    end.join("\n\n")
  end

  def all_elements_passed?(elements)
    elements.map do |element|
      resolve_path_with_dar(composition_resource, element[:expression]).first.present?
    end.all?
  end

  def composition_resource
    BundleDecorator.new(scratch_bundle).composition_resource
  end
end
