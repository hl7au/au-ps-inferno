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
    section.map { |sect| sect.code.coding.first.code }
  end

  def section_by_code(code)
    section_data = section.find { |sect| sect.code.coding.first.code == code }
    return nil if section_data.nil?

    SectionDecorator.new(section_data.to_hash)
  end

  def event_by_code(code)
    return nil if event.nil?

    event.find { |evt| event_element_code(evt) == code }
  end

  def event_element_code(event_element)
    first_code = event_element.code&.first
    return nil if first_code.nil?

    first_coding = first_code.coding&.first
    first_coding&.code
  end
  private :event_element_code
end
