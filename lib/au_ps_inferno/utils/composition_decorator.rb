require_relative 'section_decorator'

class CompositionDecorator < FHIR::Composition
  def initialize(composition)
    super(composition)
  end

  def section_by_code(code)
    SectionDecorator.new(section.find { |s| s.code.coding.first.code == code }.to_hash)
  end
end