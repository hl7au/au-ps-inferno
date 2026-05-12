# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'
require_relative '../../support/basic_test/ms_elements_populated_spec_support'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule do # rubocop:disable Metrics/BlockLength,Layout/LineLength
  include_context 'ms elements populated setup'

  let(:minimal_metadata) do # rubocop:disable Metrics/BlockLength
    {
      groups: [
        {
          resource: 'Condition',
          profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/condition',
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

  target_profile_url = 'http://hl7.org.au/fhir/ps/StructureDefinition/condition'
  resources_array = [FHIR::Condition.new(
    {
      resourceType: 'Condition',
      clinicalStatus: { coding: [{ code: 'active' }] },
      category: [{ coding: [{ code: 'problem-list-item' }] }],
      code: { coding: [{ code: '160245001' }] },
      subject: { reference: 'urn:uuid:patient-1' }
    }
  )]

  describe '#check_ms_elements_populated' do # rubocop:disable Metrics/BlockLength
    it 'returns expected result shape as array of hashes with keys :definition, :mandatory, :path, :present' do
      result = test_instance.check_ms_elements_populated(target_profile_url, resources_array)

      expect(result).to be_an(Array)
      expect(result).to all(be_a(Hash))
      expect(result.map(&:keys)).to all(match_array(%i[definition mandatory path present]))
    end

    it 'returns paths from metadata must_support elements' do
      ms_elements_paths = get_ms_elements_paths(target_profile_url)
      result = test_instance.check_ms_elements_populated(target_profile_url, resources_array)
      actual_paths = result.map { |item| item[:path] }

      expect(actual_paths).to match_array(ms_elements_paths)
    end

    it 'correctly marks mandatory for each element' do
      expected_mandatory_values = ['category', 'code', 'subject', 'subject.reference']
      expected_optional_values = ['clinicalStatus', 'verificationStatus', 'severity', 'onsetDateTime', 'abatement[x]',
                                  'note']
      result = test_instance.check_ms_elements_populated(target_profile_url, resources_array)
      mandatory_values = result.map { |item| item[:path] if item[:mandatory] }.compact
      optional_values = result.map { |item| item[:path] unless item[:mandatory] }.compact

      expect(mandatory_values).to match_array(expected_mandatory_values)
      expect(optional_values).to match_array(expected_optional_values)
    end

    it 'correctly marks presence for each element' do
      expected_values_to_populate = ['clinicalStatus', 'category', 'code', 'subject', 'subject.reference']
      expected_values_to_empty = ['verificationStatus', 'severity', 'onsetDateTime', 'abatement[x]', 'note']
      result = test_instance.check_ms_elements_populated(target_profile_url, resources_array)

      populated_values = result.map { |item| item[:path] if item[:present] }.compact
      empty_values = result.map { |item| item[:path] unless item[:present] }.compact

      expect(populated_values).to match_array(expected_values_to_populate)
      expect(empty_values).to match_array(expected_values_to_empty)
    end

    it 'returns all must-support elements as missing when no resources are provided' do
      result = test_instance.check_ms_elements_populated(target_profile_url, [])

      expect(result.map { |item| item[:present] }.uniq).to eq([false])
    end
  end
end
