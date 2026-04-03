# frozen_string_literal: true

require 'tmpdir'
require 'yaml'

require_relative '../../../spec_helper'
require_relative '../../../support/generator_metadata_manager_fixtures'

require_relative '../../../../lib/au_ps_inferno/generator/metadata_manager'

# rubocop:disable Metrics/BlockLength -- example groups follow public API surface of MetadataManager
RSpec.describe Generator::MetadataManager do
  subject(:manager) { described_class.new(ig_resources) }

  let(:ig_resources) { [] }

  describe '#initialize' do
    it 'starts with empty composition metadata' do
      expect(manager.composition_sections).to eq([])
    end
  end

  describe 'with a full minimal IG' do
    let(:ig_resources) { GeneratorMetadataManagerFixtures.full_ig_resources }

    describe '#initiate_build' do
      before { manager.initiate_build }

      it 'builds composition section metadata with codes and entry profiles' do
        problems = manager.composition_sections.find { |s| s[:id] == 'Composition.section:sectionProblems' }
        expect(problems[:code]).to eq('11450-4')
        expect(problems[:entries].first[:profiles]).to include(
          'Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition'
        )
      end

      it 'extracts mandatory and optional mustSupport element paths' do
        expect(manager.composition_mandatory_ms_elements).to include('subject')
        expect(manager.composition_optional_ms_elements).to include('custodian', 'event')
      end

      it 'extracts attester slice metadata' do
        slice = manager.composition_mandatory_ms_slices.find { |s| s[:sliceName] == 'legal' }
        expect(slice[:path]).to eq('attester')
        expect(slice[:optional_ms_sub_elements]).to include('party')
      end

      it 'populates profiles with AU PS StructureDefinitions' do
        urls = manager.instance_variable_get(:@profiles).map { |p| p[:url] }
        expect(urls).to include(
          'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition',
          'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient'
        )
      end

      it 'marks required profiles from Constants::REQUIRED_PROFILES' do
        required = manager.instance_variable_get(:@profiles).select { |p| p[:required] }
        required_urls = required.map { |p| p[:url] }
        expect(required_urls).to include('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle')
        optional = manager.instance_variable_get(:@profiles).find do |p|
          p[:url] == 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization'
        end
        expect(optional[:required]).to be false
      end

      it 'builds resources_filters from RESOURCES_FILTERS_MAPPING' do
        filters = manager.instance_variable_get(:@resources_filters)
        entry = filters.find { |f| f[:resource_profile].include?('au-ps-diagnosticresult-path') }
        expect(entry[:filters].first['path']).to eq('category.coding.code')
      end

      it 'populates normalized_sections_data' do
        expect(manager.return_normalized_sections_data).not_to be_empty
        first = manager.return_normalized_sections_data.first
        expect(first).to include('code', 'display', 'resources')
      end
    end

    describe '#metadata_to_dump' do
      before { manager.initiate_build }

      it 'includes all top-level metadata keys' do
        keys = manager.metadata_to_dump.keys
        expect(keys).to include(
          :composition_sections,
          :subject,
          :author,
          :custodian,
          :attester,
          :composition_mandatory_ms_elements,
          :profiles,
          :resources_filters,
          :normalized_sections_data
        )
      end
    end

    describe '#save_to_file' do
      it 'writes YAML that round-trips' do
        Dir.mktmpdir do |dir|
          path = File.join(dir, 'metadata.yaml')
          manager.save_to_file(path)
          data = YAML.load_file(path)
          expect(data[:composition_sections].first[:code]).to eq('11450-4')
        end
      end
    end

    describe '#normalize_section_data' do
      before { manager.initiate_build }

      it 'returns nil for unknown section id' do
        expect(manager.normalize_section_data('Composition.section:missing')).to be_nil
      end

      it 'returns a normalized hash for a known section' do
        section = manager.composition_sections.first
        normalized = manager.normalize_section_data(section[:id])
        expect(normalized['code']).to eq(section[:code])
        expect(normalized['resources']).to be_a(Hash)
      end
    end

    describe '#requirements_for_profile' do
      before { manager.initiate_build }

      it 'returns filters for a mapped Observation profile' do
        req = manager.requirements_for_profile(
          'Observation|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path'
        )
        expect(req).to include({ 'path' => 'category.coding.code', 'value' => 'laboratory' })
      end

      it 'returns empty array when profile is not mapped' do
        expect(manager.requirements_for_profile('Patient|http://example.org/fhir/foo')).to eq([])
      end
    end

    describe '#optional_ms_elements and #optional_ms_sub_elements' do
      before { manager.initiate_build }

      it 'wraps paths in expression/label hashes' do
        labels = manager.optional_ms_elements.map { |h| h[:label] }
        expect(labels).to include('custodian')
      end
    end

    describe '#optional_ms_slices' do
      before { manager.initiate_build }

      it 'is empty when all MS slices in the fixture are mandatory' do
        expect(manager.optional_ms_slices).to eq([])
      end
    end

    describe '#normalize_slice_data' do
      before { manager.initiate_build }

      it 'builds label from path and sliceName' do
        raw = manager.composition_mandatory_ms_slices.first
        normalized = manager.normalize_slice_data(raw)
        expect(normalized[:label]).to eq('attester (legal)')
      end
    end

    describe '#all_sections_data_codes' do
      it 'returns the static section code list' do
        expect(manager.all_sections_data_codes).to include('11450-4', '48765-2')
      end
    end

    describe '#required_sections_data_codes and related' do
      before { manager.initiate_build }

      it 'filters required LOINC codes' do
        codes = manager.required_sections_data_codes.map { |s| s[:code] }
        expect(codes).to include('11450-4')
      end

      it 'returns optional sections when present' do
        expect(manager.optional_sections_data_codes).to eq([])
      end
    end

    describe '#au_ps_profiles_mapping_required and #au_ps_profiles_mapping_other' do
      before { manager.initiate_build }

      it 'splits required vs other profile URL to name mappings' do
        req = manager.au_ps_profiles_mapping_required
        other = manager.au_ps_profiles_mapping_other
        expect(req).to have_key('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle')
        expect(other).to have_key('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization')
      end
    end

    describe '#composition_ms_sections_elements' do
      before { manager.initiate_build }

      it 'lists section-level MS expressions with min' do
        exprs = manager.composition_ms_sections_elements.map { |e| e[:expression] }
        expect(exprs).to include('title', 'code', 'entry')
      end
    end

    describe '#get_structure_definition_by_profile' do
      before { manager.initiate_build }

      it 'resolves a versioned canonical URL' do
        sd = manager.get_structure_definition_by_profile(
          'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient|1.0.0'
        )
        expect(sd.type).to eq('Patient')
      end
    end

    describe '#get_resources_by_type and #structure_definition_urls' do
      it 'returns only StructureDefinitions of the requested type' do
        sds = manager.get_resources_by_type('StructureDefinition')
        expect(sds).not_to be_empty
        expect(sds).to all(have_attributes(resourceType: 'StructureDefinition'))
      end

      it 'lists sorted canonical URLs' do
        urls = manager.structure_definition_urls
        expect(urls).to eq(urls.sort)
        expect(urls).to include('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition')
      end
    end

    describe '#find_structure_definition_by_base_url' do
      it 'finds by URL without version' do
        sd = manager.find_structure_definition_by_base_url('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient')
        expect(sd.type).to eq('Patient')
      end
    end

    describe '#get_structure_definition_by_type' do
      it 'returns the Composition StructureDefinition' do
        sd = manager.get_structure_definition_by_type('Composition')
        expect(sd.url).to include('au-ps-composition')
      end
    end

    describe '#path_is_not_slice?' do
      before { manager.initiate_build }

      it 'returns false for paths covered by mandatory slices' do
        expect(manager.path_is_not_slice?('attester')).to be false
      end

      it 'returns true for ordinary element paths' do
        expect(manager.path_is_not_slice?('subject')).to be true
      end
    end

    describe '#reset_composition_metadata_ivars!' do
      it 'clears built state' do
        manager.initiate_build
        manager.send(:reset_composition_metadata_ivars!)
        expect(manager.composition_sections).to eq([])
      end
    end
  end

  describe 'error handling' do
    let(:ig_resources) { GeneratorMetadataManagerFixtures.full_ig_resources }

    it 'raises when profile URL has no matching StructureDefinition' do
      expect do
        manager.get_structure_definition_by_profile('http://example.org/fhir/StructureDefinition/Unknown')
      end.to raise_error(RuntimeError, /No StructureDefinition found/)
    end
  end

  describe 'with empty IG resources' do
    it 'completes initiate_build without composition data' do
      manager.initiate_build
      expect(manager.composition_sections).to eq([])
      expect(manager.composition_mandatory_ms_elements).to eq([])
    end

    it 'raises when resolving a profile' do
      expect do
        manager.get_structure_definition_by_profile('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient')
      end.to raise_error(RuntimeError)
    end
  end
end
# rubocop:enable Metrics/BlockLength
