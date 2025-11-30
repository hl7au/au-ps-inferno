# frozen_string_literal: true

# Decorator for FHIR::Composition::Section
class SectionDecorator < FHIR::Composition::Section
  def entry_references
    entry&.map(&:reference) || []
  end

  def empty_reason_str
    er_coding = emptyReason&.coding&.first
    return unless er_coding.present?

    "#{er_coding.display} (#{er_coding.code})"
  end

  def code_display_str
    "#{code.coding.first.display} (#{code.coding.first.code})"
  end
end
