# frozen_string_literal: true

require 'fileutils'
require_relative '../../lib/au_ps_inferno/generator/hand_authored_groups_generator'

RSpec.describe Generator::HandAuthoredGroupsGenerator do
  let(:suite_version) { '0.0.0-specfixture' }
  let(:version_suffix) { '00specfixture' }
  let(:output_dir) { File.expand_path(File.join('lib', 'au_ps_inferno', suite_version)) }

  after { FileUtils.rm_rf(output_dir) }

  it 'stamps every family with the version suffix and returns their root group entries' do
    entries = described_class.new(suite_version, version_suffix).generate

    expect(entries.map { |e| e[:group_id] }).to contain_exactly(
      :"suite_au_ps_bundle_instance_#{version_suffix}",
      :"au_ps_retrieve_cs_group_#{version_suffix}",
      :"suite_retrieve_au_ps_bundle_validation_tests_#{version_suffix}",
      :"suite_generate_au_ps_using_ips_summary_validation_tests_#{version_suffix}"
    )
  end

  it 'appends the suffix to class names and ids without renaming files' do
    described_class.new(suite_version, version_suffix).generate

    root_file = File.join(output_dir, 'au_ps_bundle_instance', 'au_ps_bundle_instance.rb')
    content = File.read(root_file)

    expect(content).to include("AUPSSuiteAuPsBundleInstance#{version_suffix}")
    expect(content).to include("id :suite_au_ps_bundle_instance_#{version_suffix}")
  end

  it 'rewrites the metadata.yaml relative path for leaf-level tests to match the new nesting depth' do
    described_class.new(suite_version, version_suffix).generate

    leaf_file = File.join(
      output_dir, 'au_ps_bundle_instance', 'au_ps_composition_author',
      'suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_elements.rb'
    )

    expect(File.read(leaf_file)).to include("File.expand_path('../../metadata.yaml', __dir__)")
  end
end
