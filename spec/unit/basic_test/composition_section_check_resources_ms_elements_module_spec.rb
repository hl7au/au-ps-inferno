# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

MINIMAL_METADATA = {
  groups: [
    {
      resource: 'Condition',
      must_supports: {
        elements: [
          { path: 'clinicalStatus' },
          { path: 'verificationStatus' },
          { path: 'category' },
          { path: 'severity' },
          { path: 'code' },
          { path: 'subject' },
          { path: 'subject.reference' },
          { path: 'onsetDateTime', original_path: 'onset[x]' },
          { path: 'abatement[x]' },
          { path: 'note' }
        ]
      },
      mandatory_elements: %w[
        Condition.category
        Condition.code
        Condition.subject
        Condition.subject.reference
      ]
    }
  ]
}.freeze

CONDITION_RESOURCE_DATA = {
  resourceType: 'Condition',
  clinicalStatus: { coding: [{ code: 'active' }] },
  category: [{ coding: [{ code: 'problem-list-item' }] }],
  code: { coding: [{ code: '160245001' }] },
  subject: { reference: 'urn:uuid:patient-1' }
}.freeze

def result_by_path(path)
  result.find { |item| item[:path] == path }
end

def check_presence_parametrize(test_cases, key_to_check)
  test_cases.each do |path, expected_value|
    item = result_by_path(path)
    expect(item).not_to be_nil, "Expected result to include #{path}"
    expect(item[key_to_check]).to eq(expected_value), "Expected #{path} #{key_to_check}=#{expected_value}, got #{item[key_to_check]}"
  end
end

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule do
  let(:test_class) do
    Class.new do
      include AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule

      attr_accessor :metadata_manager, :scratch_bundle
    end
  end
  let(:test_instance) { test_class.new }
  let(:resource_type) { 'Condition' }

  let(:metadata_manager) do
    AUPSTestKit::MetadataManager.new('spec/fixtures/metadata.yaml').tap do |manager|
      allow(manager).to receive(:metadata).and_return(MINIMAL_METADATA)
    end
  end

  let(:group_metadata) { metadata_manager.group_metadata_by_resource_type(resource_type) }
  let(:resources) { [FHIR::Condition.new(CONDITION_RESOURCE_DATA)] }

  let(:result) { test_instance.check_ms_elements_populated(resource_type, resources) }

  before do
    test_instance.metadata_manager = metadata_manager
  end

  describe '#check_ms_elements_populated' do
    it 'returns expected record shape' do
      expect(result).to all(be_a(Hash))
      expect(result.map(&:keys)).to all(match_array(%i[definition mandatory path present]))
    end

    it 'returns paths from metadata must_support elements' do
      expected_paths = group_metadata[:must_supports][:elements].map { |e| e[:path] }.sort
      actual_paths = result.map { |item| item[:path] }.sort
      expect(actual_paths).to eq(expected_paths)
    end

    it 'correctly marks mandatory for each element' do
      test_cases = [
        ['category', true],
        ['code', true],
        ['subject', true],
        ['subject.reference', true],
        ['clinicalStatus', false],
        ['verificationStatus', false],
        ['severity', false],
        ['onsetDateTime', false],
        ['abatement[x]', false],
        ['note', false]
      ]
      check_presence_parametrize(test_cases, :mandatory)
    end

    it 'correctly marks presence for each element' do
      test_cases = [
        ['clinicalStatus', true],
        ['category', true],
        ['code', true],
        ['subject', true],
        ['subject.reference', true],
        ['verificationStatus', false],
        ['severity', false],
        ['onsetDateTime', false],
        ['abatement[x]', false],
        ['note', false]
      ]
      check_presence_parametrize(test_cases, :present)
    end

    context 'when no resources are provided' do
      let(:resources) { [] }

      it 'returns all must-support elements as missing' do
        expect(result.map { |item| item[:present] }.uniq).to eq([false])
      end
    end
  end
end
