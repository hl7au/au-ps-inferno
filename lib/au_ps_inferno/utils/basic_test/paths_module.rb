# frozen_string_literal: true

module AUPSTestKit
  # FHIR path population checks and formatted lists of populated elements.
  module BasicTestPathsModule
    private

    def populated_paths_info(resource, elements_array, mandatory_array: [])
      title = '## List of populated elements'
      result = elements_array.map { |element| populated_path_line(resource, element, mandatory_array) }
      [title, result.join("\n\n")].join("\n\n")
    end

    def populated_path_line(resource, element, mandatory_array)
      mandatory = mandatory_array.include?(element)
      populated = resolve_path_with_dar(resource, element).first.present?
      status = boolean_to_existent_string(populated, optional: !mandatory)

      element_fhirpath_line(resource, '', element, mandatory ? "#{status} (M)" : status) ||
        "#{status}: **#{element}**#{' (M)' if mandatory}"
    end

    def all_paths_are_populated?(resource, elements_array)
      elements_array.map do |element|
        resolve_path_with_dar(resource, element).first.present?
      end.all?
    end
  end
end
