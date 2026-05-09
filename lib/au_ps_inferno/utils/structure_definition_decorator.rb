# frozen_string_literal: true

# Decorator for FHIR::StructureDefinition to add convenience methods
class StructureDefinitionDecorator < FHIR::StructureDefinition
  def initialize(data)
    if data.is_a?(Hash)
      super
    else
      super(data.respond_to?(:source_hash) ? data.source_hash : data.to_hash)
    end
  end

  def snapshot_elements
    snapshot.element
  end

  def simple_elements(include_str: nil)
    result = snapshot_elements.select do |element|
      element.mustSupport == true
    end
    result = result.select { |element| element.path.include?(include_str.to_s) } unless include_str.nil?
    result
  end

  def extension_slices
    snapshot.element.filter { |element| element.id.include?(':') }
  end
end
