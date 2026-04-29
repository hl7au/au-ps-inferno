# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule do
  let(:test_class) do
    Class.new do
      include AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule

      attr_accessor :metadata_manager, :scratch_bundle

      def add_message(_level, _message); end
    end
  end

  let(:test_instance) { test_class.new }
  let(:resource_type) { 'Condition' }

  # Keep this minimal and local to this file
  let(:minimal_metadata) do
    {
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
    }
  end

  let(:metadata_manager) do
    AUPSTestKit::MetadataManager.new('spec/fixtures/metadata.yaml').tap do |manager|
      allow(manager).to receive(:metadata).and_return(minimal_metadata)
    end
  end

  let(:group_metadata) { metadata_manager.group_metadata_by_resource_type(resource_type) }

  let(:bundle_hash) do
    {
      resourceType: 'Bundle',
      type: 'document',
      entry: [
        {
          resource: {
            resourceType: 'Condition',
            clinicalStatus: { coding: [{ code: 'active' }] },
            category: [{ coding: [{ code: 'problem-list-item' }] }],
            code: { coding: [{ code: '160245001' }] },
            subject: { reference: 'urn:uuid:patient-1' }
          }
        }
      ]
    }
  end

  let(:resources) do
    bundle = FHIR::Bundle.new(JSON.parse(JSON.generate(bundle_hash)))
    bundle.entry.map(&:resource).select { |resource| resource.resourceType == resource_type }
  end

  let(:result) { test_instance.send(:check_ms_elements_populated, resource_type, resources) }

  before do
    test_instance.metadata_manager = metadata_manager
  end

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

    it 'keeps original polymorphic path metadata' do
      item = result_by_path('onsetDateTime')
      expect(item).not_to be_nil
      expect(item.dig(:definition, :original_path)).to eq('onset[x]')
    end

    context 'when no resources are provided' do
      let(:resources) { [] }

      it 'returns all must-support elements as missing' do
        expect(result.map { |item| item[:present] }.uniq).to eq([false])
      end
    end
  end
end
