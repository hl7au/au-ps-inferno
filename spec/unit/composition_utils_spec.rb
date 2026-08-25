# frozen_string_literal: true

require 'fhir_models'

require_relative '../../lib/au_ps_inferno/utils/section_decorator'
require_relative '../support/basic_test/basic_test_instance_setup'

RSpec.describe CompositionUtils do
  include_context 'basic test instance setup'

  def bundle_with_composition(id: nil, composition_id: nil)
    entries = [
      FHIR::Bundle::Entry.new(resource: FHIR::Patient.new),
      FHIR::Bundle::Entry.new(resource: FHIR::Composition.new(id: composition_id))
    ]
    FHIR::Bundle.new(id: id, type: 'document', entry: entries)
  end

  describe '#composition_resource_from_scratch' do
    it 'finds the Composition entry regardless of its position in the Bundle' do
      test_instance.scratch[:bundle_ips_resource] = bundle_with_composition(composition_id: 'comp-1')

      expect(test_instance.composition_resource_from_scratch.id).to eq('comp-1')
    end

    it 'returns nil when there is no Bundle in scratch' do
      test_instance.scratch[:bundle_ips_resource] = nil

      expect(test_instance.composition_resource_from_scratch).to be_nil
    end
  end

  describe '#section_fhirpath_prefix' do
    it "builds a where-clause on the section's LOINC code, relative to the Composition resource" do
      section = SectionDecorator.new(code: FHIR::CodeableConcept.new(coding: [FHIR::Coding.new(code: '11450-4')]))

      expect(test_instance.section_fhirpath_prefix(section)).to eq(
        "section.where(code.coding.code='11450-4')."
      )
    end

    it 'returns an empty string when the section has no code' do
      section = SectionDecorator.new(code: nil)

      expect(test_instance.section_fhirpath_prefix(section)).to eq('')
    end
  end

  describe '#element_fhirpath_line' do
    it 'builds a linkable "ResourceType/<id>: <expression>: <status>" line addressed at the given resource' do
      resource = FHIR::Composition.new(id: 'comp-1')

      line = test_instance.element_fhirpath_line(resource, "section.where(code.coding.code='11450-4').", 'title',
                                                 '✅ Populated')

      expect(line).to eq("Composition/comp-1: section.where(code.coding.code='11450-4').title: ✅ Populated")
    end

    it 'returns nil when the resource has no id' do
      resource = FHIR::Composition.new

      expect(test_instance.element_fhirpath_line(resource, '', 'title', '✅ Populated')).to be_nil
    end

    it 'returns nil when there is no resource to address' do
      expect(test_instance.element_fhirpath_line(nil, '', 'title', '✅ Populated')).to be_nil
    end
  end
end
