# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule do
  subject(:result) { test_instance.send(:composition_section_check_ms_pass?, sections_codes) }

  let(:test_class) do
    Class.new do
      include AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule

      attr_accessor :metadata_manager
      attr_accessor :scratch_bundle

      def add_message(_level, _message); end
    end
  end
  let(:test_instance) { test_class.new }
  let(:sections_codes) { %w[section-a section-b] }
  let(:profiles) { ['Observation|http://example.org/StructureDefinition/au-ps-observation'] }
  let(:resources) { [instance_double('FHIR::Observation', resourceType: 'Observation')] }

  def expect_sections_profiles_lookup
    expect(test_instance).to receive(:sections_profiles).with(sections_codes).and_return(profiles)
  end

  def expect_resources_to_check_lookup
    expect(test_instance).to receive(:resources_to_check_ms).with(sections_codes).and_return(resources)
  end

  def expect_profile_check(results)
    expect(test_instance).to receive(:check_resources_against_profiles)
      .with(profiles, resources)
      .and_return(results)
  end

  def stub_pipeline(results:)
    expect_sections_profiles_lookup
    expect_resources_to_check_lookup
    expect_profile_check(results)
  end

  it 'returns false when at least one check result is error' do
    stub_pipeline(results: %w[info error warning])

    expect(result).to be(false)
  end

  it 'returns true when there are warnings but no errors' do
    stub_pipeline(results: %w[info warning])

    expect(result).to be(true)
  end

  it 'returns true when there are no errors and no warnings' do
    stub_pipeline(results: %w[info info])

    expect(result).to be(true)
  end

  describe '#raw_sections_profiles' do
    subject(:raw_profiles) { test_instance.send(:raw_sections_profiles, sections_codes) }

    let(:metadata_manager) { instance_double('MetadataManager') }

    before do
      test_instance.metadata_manager = metadata_manager
    end

    it 'flattens nested section entry profiles and removes duplicates' do
      sections_metadata = [
        {
          entries: [
            { profiles: ['Observation|http://example.org/StructureDefinition/au-ps-observation'] },
            { profiles: ['MedicationRequest|http://example.org/StructureDefinition/au-ps-medicationrequest'] }
          ]
        },
        {
          entries: [
            { profiles: ['Observation|http://example.org/StructureDefinition/au-ps-observation'] }
          ]
        }
      ]

      expect(metadata_manager).to receive(:sections_metadata_by_codes).with(sections_codes).and_return(sections_metadata)

      expect(raw_profiles).to eq([
                                   'Observation|http://example.org/StructureDefinition/au-ps-observation',
                                   'MedicationRequest|http://example.org/StructureDefinition/au-ps-medicationrequest'
                                 ])
    end

    it 'returns an empty list when sections metadata is empty' do
      expect(metadata_manager).to receive(:sections_metadata_by_codes).with(sections_codes).and_return([])

      expect(raw_profiles).to eq([])
    end
  end

  describe '#sections_profiles' do
    subject(:filtered_profiles) { test_instance.send(:sections_profiles, sections_codes) }

    it "keeps only profiles containing 'au-ps'" do
      raw_profiles = [
        'Observation|http://example.org/StructureDefinition/au-ps-observation',
        'Observation|http://example.org/StructureDefinition/us-core-observation',
        'Condition|http://example.org/StructureDefinition/au-ps-condition'
      ]

      expect(test_instance).to receive(:raw_sections_profiles).with(sections_codes).and_return(raw_profiles)

      expect(filtered_profiles).to eq([
                                        'Observation|http://example.org/StructureDefinition/au-ps-observation',
                                        'Condition|http://example.org/StructureDefinition/au-ps-condition'
                                      ])
    end

    it 'returns an empty list when raw profiles are empty' do
      expect(test_instance).to receive(:raw_sections_profiles).with(sections_codes).and_return([])

      expect(filtered_profiles).to eq([])
    end
  end

  describe '#resources_to_check_ms' do
    subject(:resources_to_check) { test_instance.send(:resources_to_check_ms, sections_codes) }

    let(:scratch_bundle) { instance_double('ScratchBundle', to_hash: { resourceType: 'Bundle' }) }
    let(:bundle_resource) { instance_double('BundleDecorator') }
    let(:composition_resource) { instance_double('CompositionResource') }
    let(:entry_references) { ['Observation/123', 'Condition/456'] }
    let(:resolved_resources) { [instance_double('FHIR::Observation'), instance_double('FHIR::Condition')] }

    before do
      test_instance.scratch_bundle = scratch_bundle
      allow(BundleDecorator).to receive(:new).with(scratch_bundle.to_hash).and_return(bundle_resource)
      allow(bundle_resource).to receive(:composition_resource).and_return(composition_resource)
    end

    it 'delegates section lookup and returns matching resources' do
      expect(composition_resource).to receive(:entry_references_by_codes).with(sections_codes).and_return(entry_references)
      expect(bundle_resource).to receive(:resources_by_references).with(entry_references).and_return(resolved_resources)

      expect(resources_to_check).to eq(resolved_resources)
    end

    it 'supports empty reference lists' do
      expect(composition_resource).to receive(:entry_references_by_codes).with(sections_codes).and_return([])
      expect(bundle_resource).to receive(:resources_by_references).with([]).and_return([])

      expect(resources_to_check).to eq([])
    end
  end

  describe '#msg_line' do
    it 'formats title and text in markdown bold label format' do
      expect(test_instance.send(:msg_line, 'Profile', 'Observation — http://example.org')).to eq(
        '**Profile**: Observation — http://example.org'
      )
    end

    it 'supports empty text values' do
      expect(test_instance.send(:msg_line, 'Message', '')).to eq('**Message**: ')
    end
  end

  describe '#group_metadata_for' do
    subject(:group_metadata) { test_instance.send(:group_metadata_for, resource_type) }

    let(:resource_type) { 'Observation' }
    let(:resource_metadata_raw) { { id: 'observation-group' } }
    let(:wrapped_metadata) { instance_double('InfernoSuiteGenerator::Generator::GroupMetadata') }
    let(:metadata_manager) { instance_double('MetadataManager') }

    before do
      test_instance.metadata_manager = metadata_manager
    end

    it 'fetches raw metadata by resource type and wraps it in GroupMetadata' do
      expect(metadata_manager).to receive(:group_metadata_by_resource_type)
        .with(resource_type)
        .and_return(resource_metadata_raw)
      expect(InfernoSuiteGenerator::Generator::GroupMetadata).to receive(:new)
        .with(resource_metadata_raw)
        .and_return(wrapped_metadata)

      expect(group_metadata).to eq(wrapped_metadata)
    end
  end

  describe '#report_missing_resources' do
    subject(:report_result) { test_instance.send(:report_missing_resources, profile_info_str) }

    let(:profile_info_str) { '**Profile**: Observation — http://example.org/StructureDefinition/au-ps-observation' }

    it 'adds warning message with profile and no-resource details' do
      expect(test_instance).to receive(:msg_line).with('Message', 'No resources found')
                                                 .and_return('**Message**: No resources found')
      expect(test_instance).to receive(:add_message).with(
        'warning',
        "**Profile**: Observation — http://example.org/StructureDefinition/au-ps-observation\n\n**Message**: No resources found"
      )

      expect(report_result).to be_nil
    end
  end

  describe '#check_resources_against_profiles' do
    subject(:check_results) do
      test_instance.send(:check_resources_against_profiles, sections_profiles, resources_to_check_ms)
    end

    let(:sections_profiles) do
      [
        'Observation|http://example.org/StructureDefinition/au-ps-observation',
        'Condition|http://example.org/StructureDefinition/au-ps-condition'
      ]
    end
    let(:resources_to_check_ms) { [instance_double('FHIR::Observation'), instance_double('FHIR::Condition')] }

    it 'processes each profile with the same resources list and returns collected results' do
      expect(test_instance).to receive(:process_profile)
        .with(sections_profiles[0], resources_to_check_ms)
        .and_return('warning')
      expect(test_instance).to receive(:process_profile)
        .with(sections_profiles[1], resources_to_check_ms)
        .and_return('info')

      expect(check_results).to eq(%w[warning info])
    end

    it 'returns an empty array when no profiles are provided' do
      expect(test_instance).not_to receive(:process_profile)

      result = test_instance.send(:check_resources_against_profiles, [], resources_to_check_ms)
      expect(result).to eq([])
    end
  end

  describe '#normalize_resource_type_and_profile' do
    it 'returns resource type and profile url when profile has expected format' do
      profile = 'Observation|http://example.org/StructureDefinition/au-ps-observation'

      expect(test_instance.send(:normalize_resource_type_and_profile, profile)).to eq(
        {
          resource_type: 'Observation',
          profile_url: 'http://example.org/StructureDefinition/au-ps-observation'
        }
      )
    end

    it 'raises when profile format is invalid' do
      expect do
        test_instance.send(:normalize_resource_type_and_profile, 'Observation')
      end.to raise_error(StandardError, 'Profile is not in the correct format')
    end
  end

  describe '#process_profile' do
    subject(:process_result) { test_instance.send(:process_profile, profile, resources_to_check_ms) }

    let(:profile) { 'Observation|http://example.org/StructureDefinition/au-ps-observation' }
    let(:normalized_profile) do
      {
        resource_type: 'Observation',
        profile_url: 'http://example.org/StructureDefinition/au-ps-observation'
      }
    end
    let(:profile_info_str) { '**Profile**: Observation — http://example.org/StructureDefinition/au-ps-observation' }
    let(:metadata) { instance_double('GroupMetadata') }
    let(:checker) { instance_double('MSChecker') }

    before do
      allow(test_instance).to receive(:normalize_resource_type_and_profile).with(profile).and_return(normalized_profile)
      allow(test_instance).to receive(:msg_line).with('Profile', 'Observation — http://example.org/StructureDefinition/au-ps-observation')
                                                .and_return(profile_info_str)
      allow(MSChecker).to receive(:new).and_return(checker)
    end

    it 'delegates to report_missing_resources when no resources match profile type' do
      non_matching_resource = instance_double('FHIR::Condition', resourceType: 'Condition')
      allow(test_instance).to receive(:report_missing_resources).and_return('missing')
      expect(test_instance).to receive(:report_missing_resources).with(profile_info_str).and_return('missing')
      expect(test_instance).not_to receive(:group_metadata_for)
      expect(checker).not_to receive(:report_profile_elements_status)
      expect(test_instance).not_to receive(:add_message)

      result = test_instance.send(:process_profile, profile, [non_matching_resource])
      expect(result).to eq('missing')
    end

    it 'checks matching resources, adds message, and returns message level' do
      matching_resource = instance_double('FHIR::Observation', resourceType: 'Observation')
      other_resource = instance_double('FHIR::Condition', resourceType: 'Condition')
      allow(test_instance).to receive(:group_metadata_for).with('Observation').and_return(metadata)

      check_result = { msg_level: 'warning', message: 'Some must support elements are missing' }
      expect(checker).to receive(:report_profile_elements_status).with(metadata,
                                                                       [matching_resource]).and_return(check_result)
      expect(test_instance).to receive(:add_message).with('warning', 'Some must support elements are missing')

      result = test_instance.send(:process_profile, profile, [other_resource, matching_resource])
      expect(result).to eq('warning')
    end
  end
end
