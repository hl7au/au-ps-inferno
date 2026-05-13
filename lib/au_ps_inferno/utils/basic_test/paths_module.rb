# frozen_string_literal: true

module AUPSTestKit
  # FHIR path population checks and formatted lists of populated elements.
  module BasicTestPathsModule
    private

    def populated_paths_info(resource, elements_array, mandatory_array: [])
      title = '## List of populated elements'
      result = elements_array.map do |element|
        mandatory = mandatory_array.include?(element)
        element_str = "**#{element}**"
        element_str += ' (M)' if mandatory
        "#{boolean_to_existent_string(resolve_path_with_dar(resource, element).first.present?,
                                      optional: !mandatory)}: #{element_str}"
      end
      [title, result.join("\n\n")].join("\n\n")
    end

    def all_paths_are_populated?(resource, elements_array)
      elements_array.map do |element|
        resolve_path_with_dar(resource, element).first.present?
      end.all?
    end
  end
end
