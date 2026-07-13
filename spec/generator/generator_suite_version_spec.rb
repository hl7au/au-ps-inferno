# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/generator/suite_file_generator'

RSpec.describe Generator::SuiteFileGenerator do
  let(:fake_metadata) do
    double(
      composition_sections: [{ code: '11450-4', required: true }],
      composition_mandatory_ms_elements: %w[author date],
      composition_optional_ms_elements: %w[text],
      composition_mandatory_ms_sub_elements: %w[subject.reference],
      composition_optional_ms_sub_elements: [],
      composition_mandatory_ms_slices: [],
      composition_optional_ms_slices: [],
      profiles: [
        { url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient', name: 'AUPSPatient', required: true }
      ]
    )
  end
  let(:tmp_root) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmp_root) }

  it 'generates a suite for 1.0.0 just like any other version, without touching the hand-authored ' \
     'lib/au_ps_inferno/suite/ tree' do
    described_class.new(fake_metadata, '1.0.0', tmp_root).generate

    suite_file = File.join(tmp_root, 'generated', '1.0.0', 'suite', 'suite_1_0_0_suite.rb')
    expect(File).to exist(suite_file)

    content = File.read(suite_file)
    expect(content).to include('class AUPSSuite1_0_0 < Inferno::TestSuite')
    expect(content).to include('id :suite_1_0_0')
    expect(content).to include('AU PS 1.0.0 Test Suite')
  end

  it 'derives a version-suffixed suite id, class name, and output path from a full semantic version' do
    described_class.new(fake_metadata, '1.0.0-ballot', tmp_root).generate

    suite_file = File.join(tmp_root, 'generated', '1.0.0-ballot', 'suite', 'suite_1_0_0_ballot_suite.rb')
    expect(File).to exist(suite_file)

    content = File.read(suite_file)
    expect(content).to include('class AUPSSuite1_0_0_ballot < Inferno::TestSuite')
    expect(content).to include('id :suite_1_0_0_ballot')
    expect(content).to include('AU PS 1.0.0-ballot Test Suite')
  end

  it 'never collapses distinct version segments into the same suffix (regression: 1.0.0-preview vs ' \
     'the hand-authored 1.0.0 suite\'s "100preview" ids)' do
    described_class.new(fake_metadata, '1.0.0-preview', tmp_root).generate

    cs_group_file = File.join(
      tmp_root, 'generated', '1.0.0-preview', 'suite', 'retrieve_cs_group', 'au_ps_cs_is_valid_test.rb'
    )
    content = File.read(cs_group_file)
    expect(content).not_to include('id :au_ps_cs_is_valid_100preview')
    expect(content).to include('id :au_ps_cs_is_valid_1_0_0_preview')
  end

  it 'generates each flavor and the retrieve-CS group under their own directories' do
    described_class.new(fake_metadata, '1.1.0-ballot', tmp_root).generate

    suite_dir = File.join(tmp_root, 'generated', '1.1.0-ballot', 'suite')
    expect(File).to exist(File.join(suite_dir, 'bundle_static', 'bundle_static.rb'))
    expect(File).to exist(File.join(suite_dir, 'bundle_retrieval', 'bundle_retrieval.rb'))
    expect(File).to exist(File.join(suite_dir, 'ips_summary', 'ips_summary.rb'))
    expect(File).to exist(File.join(suite_dir, 'retrieve_cs_group', 'retrieve_cs_group.rb'))
  end

  it "points generated leaf tests at this version's own metadata.yaml, not the shared one" do
    described_class.new(fake_metadata, '1.1.0-ballot', tmp_root).generate

    leaf_file = File.join(
      tmp_root, 'generated', '1.1.0-ballot', 'suite', 'bundle_static', 'subject',
      'bundle_static_1_1_0_ballot_subject_ms_elements.rb'
    )
    content = File.read(leaf_file)
    expect(content).to include("MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))")
  end

  it 'only emits the mandatory/optional composition slice tests when the metadata has slices to cover' do
    described_class.new(fake_metadata, '1.1.0-ballot', tmp_root).generate

    group_file = File.join(tmp_root, 'generated', '1.1.0-ballot', 'suite', 'bundle_static', 'composition_ms.rb')
    content = File.read(group_file)
    expect(content).not_to include('mandatory_slices')
    expect(content).not_to include('optional_slices')
  end
end
