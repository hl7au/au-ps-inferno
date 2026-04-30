# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'
require_relative '../../support/basic_test/ms_elements_populated_spec_support'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule do
  include_context 'ms elements populated setup'

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

  target_resource_type = 'Condition'
  resources_array = [FHIR::Condition.new({
                                           resourceType: 'Condition',
                                           clinicalStatus: { coding: [{ code: 'active' }] },
                                           category: [{ coding: [{ code: 'problem-list-item' }] }],
                                           code: { coding: [{ code: '160245001' }] },
                                           subject: { reference: 'urn:uuid:patient-1' }
                                         })]

  describe '#check_ms_elements_populated' do
    it 'returns expected result shape as array of hashes with keys :definition, :mandatory, :path, :present' do
      result = test_instance.check_ms_elements_populated(target_resource_type, resources_array)

      expect(result).to be_an(Array)
      expect(result).to all(be_a(Hash))
      expect(result.map(&:keys)).to all(match_array(%i[definition mandatory path present]))
    end

    it 'returns paths from metadata must_support elements' do
      expected_paths = metadata_manager.group_metadata_by_resource_type(target_resource_type)[:must_supports][:elements].map { |e| e[:path] }.sort
      result = test_instance.check_ms_elements_populated(target_resource_type, resources_array)
      actual_paths = result.map { |item| item[:path] }.sort

      expect(actual_paths).to eq(expected_paths)
    end

    it 'correctly marks mandatory for each element' do
      result = test_instance.check_ms_elements_populated(target_resource_type, resources_array)
      expected_values = {
        'category' => true,
        'code' => true,
        'subject' => true,
        'subject.reference' => true,
        'clinicalStatus' => false,
        'verificationStatus' => false,
        'severity' => false,
        'onsetDateTime' => false,
        'abatement[x]' => false,
        'note' => false
      }

      expected_values.each do |path, expected_value|
        result_value = result.find { |item| item[:path] == path }[:mandatory]

        expect(result_value).to eq(expected_value),
                                "Expected #{path} to be #{expected_value}, got #{result_value}. Result: #{result}"
      end
    end

    it 'correctly marks presence for each element' do
      result = test_instance.check_ms_elements_populated(target_resource_type, resources_array)
      expected_values = {
        'clinicalStatus' => true,
        'category' => true,
        'code' => true,
        'subject' => true,
        'subject.reference' => true,
        'verificationStatus' => false,
        'severity' => false,
        'onsetDateTime' => false,
        'abatement[x]' => false,
        'note' => false
      }
      expected_values.each do |path, expected_value|
        result_value = result.find { |item| item[:path] == path }[:present]

        expect(result_value).to eq(expected_value),
                                "Expected #{path} to be #{expected_value}, got #{result_value}. Result: #{result}"
      end
    end

    it 'returns all must-support elements as missing when no resources are provided' do
      result = test_instance.check_ms_elements_populated(target_resource_type, [])

      expect(result.map { |item| item[:present] }.uniq).to eq([false])
    end
  end
end
