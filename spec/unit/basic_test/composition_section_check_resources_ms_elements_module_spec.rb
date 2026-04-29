# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule do
  let(:test_class) do
    Class.new do
      include AUPSTestKit::BasicTestCompositionSectionReadModule::BasicTestCompositionSectionCheckResourcesMSElementsModule

      attr_accessor :metadata_manager
      attr_accessor :scratch_bundle

      def add_message(_level, _message); end
    end
  end
  let(:test_instance) { test_class.new }

  describe 'Function to check MS elements in the resource (check_ms_elements_populated)' do
    let(:resource_type) { 'Condition' }
    let(:metadata_manager) { AUPSTestKit::MetadataManager.new('spec/fixtures/metadata.yaml') }
    let(:fixture_bundle_path) { 'spec/fixtures/resources/bundle_ms_info_min.json' }
    let(:resources) do
      bundle_json = File.read(fixture_bundle_path)
      bundle = FHIR::Bundle.new(JSON.parse(bundle_json))
      bundle.entry.map(&:resource).select { |resource| resource.resourceType == resource_type }
    end
    let(:result) { test_instance.send(:check_ms_elements_populated, resource_type, resources) }

    before do
      test_instance.metadata_manager = metadata_manager
    end

    def result_by_path(path)
      result.find { |item| item[:path] == path }
    end

    it 'returns an array of hashes' do
      expect(result).to be_an(Array)
      expect(result.all?(Hash)).to be(true)
    end

    it 'returns records with keys definition, mandatory, path and present' do
      expect_list = %i[definition mandatory path present]
      expect(result.all? { |item| item.keys.sort == expect_list }).to be(true)
    end

    it 'returns correct paths for the resource type' do
      result_paths = result.map { |item| item[:path] }.sort
      expected_elements = metadata_manager.group_metadata_by_resource_type(resource_type)[:must_supports][:elements]
      expected_paths = expected_elements.map { |element| element[:path] }.sort

      expect(result_paths).to eq(expected_paths)
    end

    it 'returns mandatory elements marked as mandatory' do
      metadata = metadata_manager.group_metadata_by_resource_type(resource_type)
      mandatory_elements_paths = metadata[:mandatory_elements].map { |element| element.gsub("#{resource_type}.", '') }
      mandatory_results = mandatory_elements_paths.map { |path| result_by_path(path)[:mandatory] == true }

      expect(mandatory_results).to all(be(true))
    end

    it 'returns optional elements marked as mandatory: false' do
      metadata = metadata_manager.group_metadata_by_resource_type(resource_type)
      all_elements_paths = metadata[:must_supports][:elements].map { |element| element[:path] }
      mandatory_elements_paths = metadata[:mandatory_elements].map { |element| element.gsub("#{resource_type}.", '') }
      optional_elements_paths = all_elements_paths - mandatory_elements_paths
      optional_results = optional_elements_paths.map { |path| result_by_path(path)[:mandatory] == false }

      expect(optional_results).to all(be(true))
    end

    it 'returns correct presence for the minimal info fixture' do
      expected_results_array = [
        { path: 'clinicalStatus', present: true },
        { path: 'category', present: true },
        { path: 'code', present: true },
        { path: 'subject', present: true },
        { path: 'subject.reference', present: true },
        { path: 'verificationStatus', present: false },
        { path: 'severity', present: false },
        { path: 'onsetDateTime', present: false },
        { path: 'abatement[x]', present: false },
        { path: 'note', present: false }
      ]

      expected_results_array.each do |expected_result|
        expect(result_by_path(expected_result[:path])[:present]).to be(expected_result[:present])
      end
    end

    it 'documents polymorphic path normalization from onset[x] to onsetDateTime' do
      onset_result = result_by_path('onsetDateTime')

      expect(onset_result).not_to be_nil
      expect(onset_result[:definition][:original_path]).to eq('onset[x]')
    end

    context 'when there are no resources to evaluate' do
      let(:resources) { [] }

      it 'returns the full Must Support checklist with all elements marked as missing' do
        expect(result.map { |item| item[:present] }.uniq).to eq([false])
        expect(result.map { |item| item[:path] }).to include('category', 'code', 'subject.reference')
      end
    end
  end
end
