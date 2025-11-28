# frozen_string_literal: true

class SectionDecorator < FHIR::Composition::Section
  def entry_references
    entry&.map(&:reference) || []
  end
end
