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

  def section_by_code(code)
    section_data = section.find { |sect| section_first_code(sect) == code }
    return nil if section_data.nil?

    SectionDecorator.new(section_data.to_hash)
  end

  def event_by_code(code)
    return nil if event.nil?

    filtered_event = event.find { |ev| ev.code&.first&.coding&.first&.code == code }
    return nil if filtered_event.nil?

    filtered_event
  end

  private

  def section_first_code(section)
    section.code&.coding&.first&.code
  end
end
