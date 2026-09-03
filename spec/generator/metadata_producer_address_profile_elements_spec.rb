# frozen_string_literal: true

require 'fhir_models'
require 'inferno_suite_generator/core/ig_resources'

require_relative '../../lib/au_ps_inferno/generator/metadata_producer'

RSpec.describe Generator::CompositionMetadataProducer do
  def ig_resources(*structure_definitions)
    InfernoSuiteGenerator::Generator::IGResources.new.tap do |resources|
      structure_definitions.each { |sd| resources.add(sd) }
    end
  end

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

      producer = described_class.new(ig_resources(sd)).tap(&:extract_address_profile_elements)

      expect(producer.address_profile_elements).to contain_exactly(
        { resource_type: 'Patient', path: 'address' },
        { resource_type: 'Patient', path: 'contact.address' }
      )
    end

    it 'excludes Address-typed elements not constrained by the au-address profile' do
      sd = structure_definition(
        type: 'Patient',
        elements: [
          address_element('Patient.address', ['http://hl7.org/fhir/StructureDefinition/Address'])
        ]
      )

      producer = described_class.new(ig_resources(sd)).tap(&:extract_address_profile_elements)

      expect(producer.address_profile_elements).to eq([])
    end

    it 'excludes elements that are not typed Address at all' do
      sd = structure_definition(
        type: 'Patient',
        elements: [
          { id: 'Patient.name', path: 'Patient.name', type: [{ code: 'HumanName' }] }
        ]
      )

      producer = described_class.new(ig_resources(sd)).tap(&:extract_address_profile_elements)

      expect(producer.address_profile_elements).to eq([])
    end

    it 'ignores StructureDefinitions outside the AU PS profile namespace' do
      sd = FHIR::StructureDefinition.new(
        resourceType: 'StructureDefinition',
        url: 'http://hl7.org/fhir/StructureDefinition/Location',
        type: 'Location',
        snapshot: { element: [address_element('Location.address',
                                              ['http://hl7.org.au/fhir/StructureDefinition/au-address'])] }
      )

      producer = described_class.new(ig_resources(sd)).tap(&:extract_address_profile_elements)

      expect(producer.address_profile_elements).to eq([])
    end
  end
end
