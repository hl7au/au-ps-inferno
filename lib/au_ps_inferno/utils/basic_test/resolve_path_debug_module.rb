# frozen_string_literal: true

module AUPSTestKit
  # Wraps Inferno's FHIRResourceNavigation#resolve_path to check simple elements for DAR extension presence.
  # Ex: birthDate DAR extension is _birthDate.extension.where(url='http://hl7.org/fhir/StructureDefinition/data-absent-reason').valueCode
  module BasicTestResolvePathDebugModule
    def resolve_path_with_dar(resource, path)
      result = eval_expression(resource, path)
      return result if result.length.positive?

      check_for_dar(resource, path)
    end

    private

    def eval_expression(resource, path)
      result = resolve_path(resource, path)
      return_values(result)
    end

    def return_values(result)
      result.length.positive? ? result : []
    end

    def check_for_dar(resource, path)
      dar_path = modify_path_to_check_for_dar(path)
      return nil if dar_path.nil?

      eval_expression(resource, dar_path)
    end

    def modify_path_to_check_for_dar(path)
      # Last path segment as primitive -> _segment.extension (FHIR JSON shadow path for extensions).
      # Single segment: birthDate -> _birthDate.extension
      # Nested: name.family -> name._family.extension
      segments = path.split('.')
      return nil if segments.empty?

      last_part = segments.last
      prefix = segments.length > 1 ? segments[0..-2].join('.') : ''
      suffix = "#{last_part}.extension"
      prefix.empty? ? suffix : "#{prefix}.#{suffix}"
    end
  end
end
