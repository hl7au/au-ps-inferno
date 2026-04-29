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

    it 'documents the expected Condition Must Support paths' do
      expect(result.map { |item| item[:path] }).to eq(
        %w[
          clinicalStatus
          verificationStatus
          category
          severity
          code
          subject
          subject.reference
          onsetDateTime
          abatement[x]
          note
        ]
      )
    end

    it 'documents which Condition Must Support elements are mandatory' do
      expected_mandatory_by_path = {
        'clinicalStatus' => false,
        'verificationStatus' => false,
        'category' => true,
        'severity' => false,
        'code' => true,
        'subject' => true,
        'subject.reference' => true,
        'onsetDateTime' => false,
        'abatement[x]' => false,
        'note' => false
      }

      expected_mandatory_by_path.each do |path, mandatory|
        expect(result_by_path(path)[:mandatory]).to eq(mandatory)
      end
    end

    it 'documents optional and mandatory presence for the minimal info fixture' do
      expect(result_by_path('clinicalStatus')[:present]).to be(true)
      expect(result_by_path('category')[:present]).to be(true)
      expect(result_by_path('code')[:present]).to be(true)
      expect(result_by_path('subject')[:present]).to be(true)
      expect(result_by_path('subject.reference')[:present]).to be(true)

      expect(result_by_path('verificationStatus')[:present]).to be(false)
      expect(result_by_path('severity')[:present]).to be(false)
      expect(result_by_path('onsetDateTime')[:present]).to be(false)
      expect(result_by_path('abatement[x]')[:present]).to be(false)
      expect(result_by_path('note')[:present]).to be(false)
    end

    it 'documents polymorphic path normalization from onset[x] to onsetDateTime' do
      onset_result = result_by_path('onsetDateTime')

      expect(onset_result).not_to be_nil
      expect(onset_result[:definition][:original_path]).to eq('onset[x]')
    end

    it 'documents nested element checks for subject and subject.reference' do
      expect(result_by_path('subject')).not_to be_nil
      expect(result_by_path('subject.reference')).not_to be_nil
    end

    context 'when Condition is minimally populated (warning fixture)' do
      let(:fixture_bundle_path) { 'spec/fixtures/resources/bundle_ms_warning_min.json' }

      it 'keeps mandatory fields present and optional fields missing in the same way as info fixture' do
        expect(result_by_path('category')[:present]).to be(true)
        expect(result_by_path('code')[:present]).to be(true)
        expect(result_by_path('subject.reference')[:present]).to be(true)
        expect(result_by_path('verificationStatus')[:present]).to be(false)
        expect(result_by_path('onsetDateTime')[:present]).to be(false)
      end
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
