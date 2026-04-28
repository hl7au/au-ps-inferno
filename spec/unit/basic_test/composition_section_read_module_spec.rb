# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule do
  let(:test_class) do
    Class.new do
      include AUPSTestKit::BasicTestCompositionSectionReadModule

      attr_accessor :scratch_bundle
      attr_accessor :metadata_manager

      def add_message(_level, _message); end
      def assert(_condition, _message); end
      def check_bundle_exists_in_scratch; end
    end
  end
  let(:test_instance) { test_class.new }

  describe '#permitted_resource_types' do
    it 'extracts resource types from profile declarations and removes duplicates' do
      section_metadata = {
        entries: [
          { profiles: ['Observation|http://example.org/StructureDefinition/au-ps-observation'] },
          { profiles: ['Condition|http://example.org/StructureDefinition/au-ps-condition'] },
          { profiles: ['Observation|http://example.org/StructureDefinition/au-ps-observation-v2'] }
        ]
      }

      result = test_instance.send(:permitted_resource_types, section_metadata)

      expect(result).to eq(%w[Observation Condition])
    end

    it 'returns profile token as-is when no separator is present' do
      section_metadata = {
        entries: [
          { profiles: ['MedicationRequest'] }
        ]
      }

      result = test_instance.send(:permitted_resource_types, section_metadata)

      expect(result).to eq(['MedicationRequest'])
    end
  end

  describe '#composition_section_ref_read_issues' do
    let(:ref) { 'Observation/123' }
    let(:bundle_resource) { instance_double('BundleDecorator') }

    it 'returns not-found issue when reference does not resolve' do
      unresolved_resource = instance_double('FHIR::Resource', blank?: true, present?: false)
      allow(bundle_resource).to receive(:resource_by_reference).with(ref).and_return(unresolved_resource)

      issues = test_instance.send(:composition_section_ref_read_issues, ref, bundle_resource, %w[Observation])

      expect(issues).to eq(["Resource not found for reference: #{ref}"])
    end

    it 'returns invalid-type issue when resolved resource type is not permitted' do
      resource = instance_double('FHIR::Condition', blank?: false, present?: true, resourceType: 'Condition')
      allow(bundle_resource).to receive(:resource_by_reference).with(ref).and_return(resource)

      issues = test_instance.send(:composition_section_ref_read_issues, ref, bundle_resource, %w[Observation])

      expect(issues).to eq([
                             'Resource type: Condition is not in the list of expected resource types: ["Observation"]'
                           ])
    end

    it 'returns no issues when resolved resource type is permitted' do
      resource = instance_double('FHIR::Observation', blank?: false, present?: true, resourceType: 'Observation')
      allow(bundle_resource).to receive(:resource_by_reference).with(ref).and_return(resource)

      issues = test_instance.send(:composition_section_ref_read_issues, ref, bundle_resource, %w[Observation])

      expect(issues).to eq([])
    end
  end

  describe '#read_composition_section_issues' do
    let(:section_metadata) { { code: 'history' } }
    let(:composition_resource) { instance_double('CompositionDecorator') }
    let(:bundle_resource) { instance_double('BundleDecorator') }

    it 'returns missing-section issue when section is blank' do
      missing_section = instance_double('Section', blank?: true)
      allow(composition_resource).to receive(:section_by_code).with('history').and_return(missing_section)

      issues = test_instance.send(:read_composition_section_issues, section_metadata, composition_resource,
                                  bundle_resource)

      expect(issues).to eq(['No composition section found for code: history'])
    end

    it 'aggregates per-reference issues when section exists' do
      section = instance_double('Section', blank?: false, entry_references: %w[Observation/1 Condition/2])
      allow(composition_resource).to receive(:section_by_code).with('history').and_return(section)
      allow(test_instance).to receive(:permitted_resource_types).with(section_metadata).and_return(%w[Observation
                                                                                                      Condition])
      expect(test_instance).to receive(:composition_section_ref_read_issues)
        .with('Observation/1', bundle_resource, %w[Observation Condition])
        .and_return(['issue-a'])
      expect(test_instance).to receive(:composition_section_ref_read_issues)
        .with('Condition/2', bundle_resource, %w[Observation Condition])
        .and_return(%w[issue-b issue-c])

      issues = test_instance.send(:read_composition_section_issues, section_metadata, composition_resource,
                                  bundle_resource)

      expect(issues).to eq(%w[issue-a issue-b issue-c])
    end
  end

  describe '#empty_section_entry_reason_line' do
    it 'returns formatted emptyReason text when present' do
      section = instance_double('Section', empty_reason_str: 'no-content')

      result = test_instance.send(:empty_section_entry_reason_line, section)

      expect(result).to eq('emptyReason: no-content')
    end

    it 'returns fallback text when emptyReason is blank' do
      section = instance_double('Section', empty_reason_str: nil)

      result = test_instance.send(:empty_section_entry_reason_line, section)

      expect(result).to eq('No entries; no emptyReason.')
    end
  end

  describe '#get_section_entry_index' do
    let(:section_metadata) { { code: 'history' } }
    let(:bundle_resource) { instance_double('BundleDecorator') }
    let(:composition_resource) { instance_double('CompositionDecorator') }
    let(:ref) { 'Observation/123' }

    before do
      allow(bundle_resource).to receive(:composition_resource).and_return(composition_resource)
    end

    it 'returns nil when section is not found' do
      missing_section = instance_double('Section', blank?: true)
      allow(composition_resource).to receive(:section_by_code).with('history').and_return(missing_section)

      result = test_instance.send(:get_section_entry_index, section_metadata, bundle_resource, ref)

      expect(result).to be_nil
    end

    it 'returns entry index from section when section is present' do
      section = instance_double('Section', blank?: false)
      allow(composition_resource).to receive(:section_by_code).with('history').and_return(section)
      expect(section).to receive(:get_entry_index_by_reference).with(ref).and_return(3)

      result = test_instance.send(:get_section_entry_index, section_metadata, bundle_resource, ref)

      expect(result).to eq(3)
    end
  end

  describe '#composition_section_entry_line_unresolved' do
    it 'formats unresolved reference message' do
      ref = 'Observation/123'

      result = test_instance.send(:composition_section_entry_line_unresolved, ref)

      expect(result).to eq('**Observation/123** -> ❌ Reference does not resolve')
    end
  end

  describe '#composition_section_entry_line_bad_type' do
    it 'formats invalid resource type message with index and reference' do
      result = test_instance.send(:composition_section_entry_line_bad_type, 2, 'Observation/123')

      expect(result).to eq('entry[2]: **Observation/123** -> ❌ Invalid resource type')
    end
  end

  describe '#composition_section_entry_line_resolved' do
    it 'formats resolved line with meta.profile values' do
      meta = instance_double('Meta', profile: ['http://example.org/StructureDefinition/p1',
                                               'http://example.org/StructureDefinition/p2'])
      resource = instance_double('FHIR::Observation', meta: meta, resourceType: 'Observation')

      result = test_instance.send(:composition_section_entry_line_resolved, 1, 'Observation/123', resource)

      expect(result).to eq(
        'entry[1]: **Observation/123** -> Observation (meta.profile: ' \
        'http://example.org/StructureDefinition/p1, http://example.org/StructureDefinition/p2)'
      )
    end

    it 'formats resolved line with no meta.profile suffix when profiles are missing' do
      resource = instance_double('FHIR::Observation', meta: nil, resourceType: 'Observation')

      result = test_instance.send(:composition_section_entry_line_resolved, 0, 'Observation/123', resource)

      expect(result).to eq('entry[0]: **Observation/123** -> Observation (no meta.profile)')
    end
  end

  describe '#composition_section_read_list_body' do
    let(:bundle_resource) { instance_double('BundleDecorator') }
    let(:section_code) { 'history' }
    let(:section_metadata) { { code: 'history' } }

    it 'returns missing-section message when section is blank' do
      section = instance_double('Section', blank?: true)

      result = test_instance.send(:composition_section_read_list_body, section, bundle_resource, section_code,
                                  section_metadata)

      expect(result).to eq('No composition section found for code: history')
    end

    it 'returns empty section reason when there are no entry references' do
      section = instance_double('Section', blank?: false, entry_references: [])
      expect(test_instance).to receive(:empty_section_entry_reason_line).with(section).and_return('No entries; no emptyReason.')

      result = test_instance.send(:composition_section_read_list_body, section, bundle_resource, section_code,
                                  section_metadata)

      expect(result).to eq('No entries; no emptyReason.')
    end

    it 'formats and joins entry lines for all references' do
      section = instance_double('Section', blank?: false, entry_references: %w[Observation/1 Condition/2])
      expect(test_instance).to receive(:format_composition_section_entry_line)
        .with('Observation/1', bundle_resource, section_metadata)
        .and_return('line-1')
      expect(test_instance).to receive(:format_composition_section_entry_line)
        .with('Condition/2', bundle_resource, section_metadata)
        .and_return('line-2')

      result = test_instance.send(:composition_section_read_list_body, section, bundle_resource, section_code,
                                  section_metadata)

      expect(result).to eq("line-1\n\nline-2")
    end
  end

  describe '#composition_section_read_report_message' do
    let(:section) { instance_double('Section') }
    let(:bundle_resource) { instance_double('BundleDecorator') }
    let(:section_code) { 'history' }

    it 'uses short label in header when present' do
      section_metadata = { code: 'history', short: 'History' }
      expect(test_instance).to receive(:composition_section_read_list_body)
        .with(section, bundle_resource, section_code, section_metadata)
        .and_return('body text')

      result = test_instance.send(
        :composition_section_read_report_message,
        section_metadata,
        section,
        bundle_resource,
        section_code
      )

      expect(result).to eq("History (history)\n\nbody text")
    end

    it 'uses section code as header when short label is blank' do
      section_metadata = { code: 'history', short: nil }
      expect(test_instance).to receive(:composition_section_read_list_body)
        .with(section, bundle_resource, section_code, section_metadata)
        .and_return('body text')

      result = test_instance.send(
        :composition_section_read_report_message,
        section_metadata,
        section,
        bundle_resource,
        section_code
      )

      expect(result).to eq("history\n\nbody text")
    end
  end

  describe '#format_composition_section_entry_line' do
    let(:ref) { 'Observation/123' }
    let(:bundle_resource) { instance_double('BundleDecorator') }
    let(:section_metadata) { { code: 'history' } }
    let(:index) { 2 }

    it 'returns unresolved line when reference does not resolve' do
      resource = instance_double('FHIR::Resource', blank?: true)
      allow(bundle_resource).to receive(:resource_by_reference).with(ref).and_return(resource)
      allow(test_instance).to receive(:get_section_entry_index).with(section_metadata, bundle_resource,
                                                                     ref).and_return(index)
      expect(test_instance).to receive(:composition_section_entry_line_unresolved).with(ref).and_return('unresolved line')

      result = test_instance.send(:format_composition_section_entry_line, ref, bundle_resource, section_metadata)

      expect(result).to eq('unresolved line')
    end

    it 'returns bad-type line when resolved resource type is not permitted' do
      resource = instance_double('FHIR::Condition', blank?: false, resourceType: 'Condition')
      allow(bundle_resource).to receive(:resource_by_reference).with(ref).and_return(resource)
      allow(test_instance).to receive(:get_section_entry_index).with(section_metadata, bundle_resource,
                                                                     ref).and_return(index)
      allow(test_instance).to receive(:permitted_resource_types).with(section_metadata).and_return(%w[Observation])
      expect(test_instance).to receive(:composition_section_entry_line_bad_type).with(index,
                                                                                      ref).and_return('bad type line')

      result = test_instance.send(:format_composition_section_entry_line, ref, bundle_resource, section_metadata)

      expect(result).to eq('bad type line')
    end

    it 'returns resolved line when resource type is permitted' do
      resource = instance_double('FHIR::Observation', blank?: false, resourceType: 'Observation')
      allow(bundle_resource).to receive(:resource_by_reference).with(ref).and_return(resource)
      allow(test_instance).to receive(:get_section_entry_index).with(section_metadata, bundle_resource,
                                                                     ref).and_return(index)
      allow(test_instance).to receive(:permitted_resource_types).with(section_metadata).and_return(%w[Observation])
      expect(test_instance).to receive(:composition_section_entry_line_resolved)
        .with(index, ref, resource)
        .and_return('resolved line')

      result = test_instance.send(:format_composition_section_entry_line, ref, bundle_resource, section_metadata)

      expect(result).to eq('resolved line')
    end
  end

  describe '#composition_section_references_resolution_issues?' do
    let(:section_metadata) { { code: 'history' } }
    let(:composition_resource) { instance_double('CompositionDecorator') }
    let(:bundle_resource) { instance_double('BundleDecorator') }
    let(:section) { instance_double('Section') }

    before do
      allow(composition_resource).to receive(:section_by_code).with('history').and_return(section)
    end

    it 'adds info message and returns true when no issues are found' do
      allow(test_instance).to receive(:read_composition_section_issues)
        .with(section_metadata, composition_resource, bundle_resource)
        .and_return([])
      allow(test_instance).to receive(:composition_section_read_report_message)
        .with(section_metadata, section, bundle_resource, 'history')
        .and_return('report text')
      expect(test_instance).to receive(:add_message).with('info', 'report text')

      result = test_instance.send(
        :composition_section_references_resolution_issues?,
        section_metadata,
        composition_resource,
        bundle_resource
      )

      expect(result).to be(true)
    end

    it 'adds error message and returns false when issues exist' do
      allow(test_instance).to receive(:read_composition_section_issues)
        .with(section_metadata, composition_resource, bundle_resource)
        .and_return(['issue'])
      allow(test_instance).to receive(:composition_section_read_report_message)
        .with(section_metadata, section, bundle_resource, 'history')
        .and_return('report text')
      expect(test_instance).to receive(:add_message).with('error', 'report text')

      result = test_instance.send(
        :composition_section_references_resolution_issues?,
        section_metadata,
        composition_resource,
        bundle_resource
      )

      expect(result).to be(false)
    end
  end

  describe '#composition_sections_references_resolution_pass?' do
    let(:sections_codes) { %w[history medications] }
    let(:scratch_bundle) { instance_double('ScratchBundle', to_hash: { resourceType: 'Bundle' }) }
    let(:metadata_manager) { instance_double('MetadataManager') }
    let(:bundle_resource) { instance_double('BundleDecorator') }
    let(:composition_resource) { instance_double('CompositionDecorator') }
    let(:sections_metadata) { [{ code: 'history' }, { code: 'medications' }] }

    before do
      test_instance.scratch_bundle = scratch_bundle
      test_instance.metadata_manager = metadata_manager
      allow(BundleDecorator).to receive(:new).with(scratch_bundle.to_hash).and_return(bundle_resource)
      allow(bundle_resource).to receive(:composition_resource).and_return(composition_resource)
      allow(metadata_manager).to receive(:sections_metadata_by_codes).with(sections_codes).and_return(sections_metadata)
    end

    it 'returns true when all section checks pass' do
      expect(test_instance).to receive(:composition_section_references_resolution_issues?)
        .with(sections_metadata[0], composition_resource, bundle_resource)
        .and_return(true)
      expect(test_instance).to receive(:composition_section_references_resolution_issues?)
        .with(sections_metadata[1], composition_resource, bundle_resource)
        .and_return(true)

      result = test_instance.send(:composition_sections_references_resolution_pass?, sections_codes)

      expect(result).to be(true)
    end

    it 'returns false when at least one section check fails' do
      expect(test_instance).to receive(:composition_section_references_resolution_issues?)
        .with(sections_metadata[0], composition_resource, bundle_resource)
        .and_return(true)
      expect(test_instance).to receive(:composition_section_references_resolution_issues?)
        .with(sections_metadata[1], composition_resource, bundle_resource)
        .and_return(false)

      result = test_instance.send(:composition_sections_references_resolution_pass?, sections_codes)

      expect(result).to be(false)
    end
  end

  describe '#read_composition_sections_info' do
    let(:sections_codes) { %w[history medications] }
    let(:failed_msg) { 'Some of the sections are not populated correctly.' }

    it 'checks bundle presence, runs both checks, and asserts both results' do
      expect(test_instance).to receive(:check_bundle_exists_in_scratch)
      expect(test_instance).to receive(:composition_sections_references_resolution_pass?)
        .with(sections_codes)
        .and_return(true)
      expect(test_instance).to receive(:composition_section_check_ms_pass?)
        .with(sections_codes)
        .and_return(false)
      expect(test_instance).to receive(:assert).with(true, failed_msg)
      expect(test_instance).to receive(:assert).with(false, failed_msg)

      test_instance.send(:read_composition_sections_info, sections_codes)
    end
  end
end
