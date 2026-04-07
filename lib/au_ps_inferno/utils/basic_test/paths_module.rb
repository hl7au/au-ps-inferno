# frozen_string_literal: true

module AUPSTestKit
  # FHIR path population checks and formatted lists of populated elements.
  module BasicTestPathsModule
    private

    def populated_paths_info(resource, elements_array)
      title = '## List of populated elements'
      result = elements_array.map do |element|
        "#{boolean_to_existent_string(resolve_path_with_dar(resource, element).first.present?)}: **#{element}**"
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
