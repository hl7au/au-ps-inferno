# frozen_string_literal: true

# Decorator for FHIR::Composition::Section
class SectionDecorator < FHIR::Composition::Section
  def get_entry_index_by_reference(reference)
    entry&.index { |entr| entr.reference == reference }
  end

  def entry_references
    entry&.map(&:reference) || []
  end

  def empty_reason_str
    er_coding = emptyReason&.coding&.first
    return unless er_coding.present?

    "#{er_coding.display} (#{er_coding.code})"
  end

  def code_display_str
    "#{code.coding.first.display || title} (#{code.coding.first.code})"
  end
end
