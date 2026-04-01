# frozen_string_literal: true

module AUPSTestKit
  # Wraps Inferno's FHIRResourceNavigation#resolve_path to check simple elements for DAR extension presence.
  # Ex: birthDate DAR extension is _birthDate.extension.where(url='http://hl7.org/fhir/StructureDefinition/data-absent-reason').valueCode
  module BasicTestResolvePathDebugModule
    DAR_EXTENSION_URL = 'http://hl7.org/fhir/StructureDefinition/data-absent-reason'

    def resolve_path_with_dar(resource, path)
      result = eval_expression(resource, path)
      return result if result.length.positive?

      check_for_dar(resource, path)
    end

    def resolve_slice(resource, path, profile)
      # Path may by only extension or identifier
      case path
      when 'extension'
        [resolve_extension(resource, path, profile)]
      when 'identifier'
        [resolve_identifier(resource, path, profile)]
      else
        []
      end
    end

    private

    def resolve_extension(resource, path, profile)
      result = resolve_path(resource, path)
      return nil if result.empty?

      target_extension = result.find { |item| item.url == profile }
      return nil if target_extension.nil?

      target_extension.value
    end

    def resolve_identifier(resource, path, profile)
      result = resolve_path(resource, path)
      return nil if result.empty?

      target_identifier = result.find { |item| item.system == profile }
      return nil if target_identifier.nil?

      info "Resolve identifier: #{target_identifier.inspect}"
      target_identifier.value
    end

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
      # info resource.source_contents
      # info scratch_bundle.source_contents
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
