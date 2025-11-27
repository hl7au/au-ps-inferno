class SectionDecorator < FHIR::Composition::Section
  def initialize(section)
    super(section)
  end

  def entry_references
    entry&.map { |e| e.reference } || []
  end
end