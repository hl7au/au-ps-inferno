# frozen_string_literal: true

require 'fhir_models'

require_relative '../../lib/au_ps_inferno/utils/section_decorator'
require_relative '../support/basic_test/basic_test_instance_setup'

RSpec.describe CompositionUtils do
  include_context 'basic test instance setup'

  def bundle_with_composition_at(index)
    entries = Array.new(index) { FHIR::Bundle::Entry.new(resource: FHIR::Patient.new) }
    entries << FHIR::Bundle::Entry.new(resource: FHIR::Composition.new)
    FHIR::Bundle.new(type: 'document', entry: entries)
  end

  describe '#composition_fhirpath_prefix' do
    it 'points at the Composition entry by its actual index in the Bundle' do
      test_instance.scratch[:bundle_ips_resource] = bundle_with_composition_at(2)

      expect(test_instance.composition_fhirpath_prefix).to eq('Bundle.entry[2].resource.')
    end

    it 'returns an empty string when there is no Bundle in scratch' do
      test_instance.scratch[:bundle_ips_resource] = nil

      expect(test_instance.composition_fhirpath_prefix).to eq('')
    end
  end

  describe '#section_fhirpath_prefix' do
    it "builds a where-clause on the section's LOINC code" do
      section = SectionDecorator.new(code: FHIR::CodeableConcept.new(coding: [FHIR::Coding.new(code: '11450-4')]))

      expect(test_instance.section_fhirpath_prefix(section)).to eq(
        "Bundle.entry.where(resource is Composition).resource.section.where(code.coding.code='11450-4')."
      )
    end

    it 'returns an empty string when the section has no code' do
      section = SectionDecorator.new(code: nil)

      expect(test_instance.section_fhirpath_prefix(section)).to eq('')
    end
  end
end
