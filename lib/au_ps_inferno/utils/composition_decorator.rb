# frozen_string_literal: true

require_relative 'section_decorator'

# Decorator for FHIR::Composition to add convenience methods
class CompositionDecorator < FHIR::Composition
  def section_codes
    section.map { |s| s.code.coding.first.code }
  end

  def section_by_code(code)
    section_data = section.find { |s| s.code.coding.first.code == code }
    return nil if section_data.nil?

    SectionDecorator.new(section_data.to_hash)
  end
end
