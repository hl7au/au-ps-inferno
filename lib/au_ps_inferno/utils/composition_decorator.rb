require_relative 'section_decorator'

class CompositionDecorator < FHIR::Composition
  def initialize(composition)
    super(composition)
  end

  def section_by_code(code)
    section_data = section.find { |s| s.code.coding.first.code == code }
    if section_data.nil?
      return nil
    end

    SectionDecorator.new(section_data.to_hash)
  end
end