# frozen_string_literal: true

# Decorator for FHIR::Composition::Section
class SectionDecorator < FHIR::Composition::Section
  def entry_references
    entry&.map(&:reference) || []
  end
end
