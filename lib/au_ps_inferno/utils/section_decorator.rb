# frozen_string_literal: true

# Decorator for FHIR::Composition::Section
class SectionDecorator < FHIR::Composition::Section
  def entry_references
    entry&.map(&:reference) || []
  end

  def code_display_str
    "#{code.coding.first.display} (#{code.coding.first.code})"
  end
end
