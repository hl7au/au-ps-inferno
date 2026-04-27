# frozen_string_literal: true

require_relative 'section_decorator'

# Decorator for FHIR::Composition to add convenience methods
class CompositionDecorator < FHIR::Composition
  def initialize(data)
    if data.is_a?(Hash)
      super
    else
      super(data.to_hash)
    end
  end

  def section_codes
    section.map { |sect| section_first_code(sect) }.compact
  end

  def entry_references_by_codes(codes)
    sections = sections_by_codes(codes).compact
    sections.map(&:entry_references).flatten
  end

  def sections_by_codes(codes)
    codes.map { |code| section_by_code(code) }
  end

  def section_by_code(code)
    section_data = section.find { |sect| section_first_code(sect) == code }
    return nil if section_data.nil?

    SectionDecorator.new(section_data.to_hash)
  end

  def event_by_code(code)
    return nil if event.nil?

    event.find { |elem| event_element_code(elem) == code }
  end

  private

  def event_element_code(event_elem)
    cc = event_elem.code&.first
    return nil if cc.nil?

    cc.coding&.first&.code
  end

  def section_first_code(section)
    cc = section.code
    return nil if cc.nil?

    cc.coding&.first&.code
  end
end
