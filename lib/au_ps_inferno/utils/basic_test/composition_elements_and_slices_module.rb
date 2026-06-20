# frozen_string_literal: true

require 'inferno_suite_generator/test_utils/ms_checker'

module AUPSTestKit
  # Composition Must Support conformance presented as a single unified list (mandatory + optional
  # elements, sub-elements of complex elements, and the careProvisioningEvent slice) in the same
  # nested IG-profile format as the profile Must Support lists (x.4.2): "✅ Populated: path (M)",
  # sub-elements nested with "|-", collapsed under absent optional parents.
  module BasicTestCompositionElementsAndSlicesModule
    COMPOSITION_PROFILE_URL = 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition'

    private

    def validate_composition_must_support(mandatory_elements, optional_elements, mandatory_sub, optional_sub, slices)
      composition = composition_resource_from_scratch
      return false unless composition.present?

      rows = composition_ms_rows(composition,
                                 mandatory_elements: mandatory_elements, optional_elements: optional_elements,
                                 mandatory_sub: mandatory_sub, optional_sub: optional_sub, slices: slices)
      visible = rows.select { |row| row[:applicable] }
      level = composition_ms_level(visible)
      add_message(level, composition_ms_report(level, visible))
      assert composition_ms_mandatory_ok?(visible), 'Mandatory Must Support elements are not populated.'
    end

    def composition_ms_rows(composition, lists)
      subs = labelled_paths(lists[:mandatory_sub], lists[:optional_sub])
      parents = labelled_paths(lists[:mandatory_elements], lists[:optional_elements])
      element_rows = parents.flat_map { |path, mandatory| composition_element_rows(composition, path, mandatory, subs) }
      element_rows + lists[:slices].flat_map { |slice| composition_slice_rows(composition, slice) }
    end

    # Pair each path with whether it is mandatory: [[path, true], [path, false], ...].
    def labelled_paths(mandatory, optional)
      mandatory.map { |path| [path, true] } + optional.map { |path| [path, false] }
    end

    # One parent row plus a row for each of its Must Support sub-elements. Sub-elements are only
    # "applicable" (shown / asserted) when the parent element is itself populated.
    def composition_element_rows(composition, path, mandatory, subs)
      present = composition_path_present?(composition, path)
      rows = [composition_ms_row(path, mandatory, false, present, true)]
      subs.select { |sub_path, _| sub_path.start_with?("#{path}.") }.each do |sub_path, sub_mandatory|
        present_sub = composition_path_present?(composition, sub_path)
        rows << composition_ms_row(sub_path, sub_mandatory, true, present_sub, present)
      end
      rows
    end

    def composition_slice_rows(composition, slice)
      label = "#{slice[:path]}:#{slice[:sliceName]}"
      present = composition_slice_present?(composition, slice)
      [composition_ms_row(label, false, false, present, true)] +
        composition_slice_sub_rows(composition, slice, label, present)
    end

    def composition_slice_sub_rows(composition, slice, label, present)
      subs = slice[:mandatory_ms_sub_elements].map { |s| [s, true] } +
             slice[:optional_ms_sub_elements].map { |s| [s, false] }
      subs.map do |sub, mandatory|
        sub_present = composition_path_present?(composition, "#{slice[:path]}.#{sub}")
        composition_ms_row("#{label}.#{sub}", mandatory, true, sub_present, present)
      end
    end

    def composition_slice_present?(composition, slice)
      return composition.event_by_code('PCPR').present? if slice[:sliceName] == 'careProvisioningEvent'

      composition_path_present?(composition, slice[:path])
    end

    def composition_ms_row(path, mandatory, child, present, applicable)
      { path: path, mandatory: mandatory, child: child, present: present, applicable: applicable }
    end

    def composition_path_present?(composition, path)
      resolve_path_with_dar(composition, path).first.present?
    end

    def composition_ms_level(rows)
      return 'error' if rows.any? { |row| row[:mandatory] && !row[:present] }
      return 'warning' if rows.any? { |row| !row[:mandatory] && !row[:present] }

      'info'
    end

    def composition_ms_mandatory_ok?(rows)
      rows.none? { |row| row[:mandatory] && !row[:present] }
    end

    def composition_ms_report(level, rows)
      header = composition_ms_header(level)
      lines = rows.map { |row| composition_ms_line(row) }
      [header,
       "**Profile**: Composition — #{COMPOSITION_PROFILE_URL}",
       'List of Must Support elements populated or missing',
       *lines].join("\n\n")
    end

    def composition_ms_header(level)
      case level
      when 'error' then InfernoSuiteGenerator::MSChecker::MANDATORY_ERROR_MS_MESSAGE
      when 'warning' then InfernoSuiteGenerator::MSChecker::OPTIONAL_MS_WARNING_MESSAGE
      else InfernoSuiteGenerator::MSChecker::MS_OKAY_MESSAGE
      end
    end

    def composition_ms_line(row)
      icon = if row[:present]
               '✅ Populated'
             else
               row[:mandatory] ? '❌ Missing' : '⚠️ Missing'
             end
      text = "#{icon}: #{row[:path]}"
      text += ' (M)' if row[:mandatory]
      row[:child] ? "|- #{text}" : text
    end
  end
end
