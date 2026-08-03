# frozen_string_literal: true

require 'fhir_models'

require_relative '../../lib/au_ps_inferno/generator/metadata_manager'

RSpec.describe Generator::MetadataManager do
  def structure_definition(type:, elements:)
    FHIR::StructureDefinition.new(
      resourceType: 'StructureDefinition',
      url: "http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-#{type.downcase}",
      type: type,
      snapshot: { element: elements }
    )
  end

  def address_element(path, profiles)
    { id: path, path: path, type: [{ code: 'Address', profile: profiles }] }
  end

  describe '#extract_address_profile_elements' do
    it 'captures every resource type/path whose Address element is constrained by au-address' do
      sd = structure_definition(
        type: 'Patient',
        elements: [
          address_element('Patient.address', ['http://hl7.org.au/fhir/StructureDefinition/au-address']),
          address_element('Patient.contact.address', ['http://hl7.org.au/fhir/StructureDefinition/au-address'])
        ]
      )

      manager = described_class.new([sd])

      expect(manager.extract_address_profile_elements).to contain_exactly(
        { resource_type: 'Patient', path: 'address' },
        { resource_type: 'Patient', path: 'contact.address' }
      )
    end

    it 'excludes Address-typed elements not constrained by the au-address profile' do
      sd = structure_definition(
        type: 'Location',
        elements: [
          address_element('Location.address', ['http://hl7.org/fhir/StructureDefinition/Address'])
        ]
      )

      manager = described_class.new([sd])

      expect(manager.extract_address_profile_elements).to eq([])
    end

    it 'excludes elements that are not typed Address at all' do
      sd = structure_definition(
        type: 'Patient',
        elements: [
          { id: 'Patient.name', path: 'Patient.name', type: [{ code: 'HumanName' }] }
        ]
      )

      manager = described_class.new([sd])

      expect(manager.extract_address_profile_elements).to eq([])
    end
  end
end
