# frozen_string_literal: true

module AUPSTestKit
  # FHIR path population checks and formatted lists of populated elements.
  module BasicTestPathsModule
    private

    def populated_paths_info(resource, elements_array)
      title = '## List of populated elements'
      result = elements_array.map do |element|
        "#{boolean_to_existent_string(resolve_path(resource, element).first.present?)}: **#{element}**"
      end
      [title, result.join("\n\n")].join("\n\n")
    end

    def populated_paths_info_raw(resource, elements_array)
      elements_array.map do |element|
        "#{boolean_to_existent_string(resolve_path(resource, element).first.present?)}: **#{element}**"
      end
    end

    def all_paths_are_populated?(resource, elements_array)
      elements_array.map do |element|
        resolve_path(resource, element).first.present?
      end.all?
    end

    def populated_elements_in_resource?(fhirpath_to_get_resource, elements_array)
      return false unless scratch_bundle.present?

      resource = resolve_path(scratch_bundle, fhirpath_to_get_resource).first
      return false unless resource.present?

      info populated_paths_info(resource, elements_array)
      all_paths_are_populated?(resource, elements_array)
    end
  end
end
