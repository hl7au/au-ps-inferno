# frozen_string_literal: true

require 'json'
require 'tmpdir'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'
require_relative '../../scripts/sync_ig_and_generate_suite'

RSpec.describe 'scripts/sync_ig_and_generate_suite.rb' do
  let(:root_dir) { Dir.mktmpdir('au_ps_sync_spec') }
  let(:base_config) do
    JSON.parse(File.read(File.expand_path('../../inferno_suite_generator.config.1.0.0.json', __dir__)))
  end

  before { stub_const('ROOT_DIR', root_dir) }
  after { FileUtils.remove_entry(root_dir) }

  it 'scaffolds a suite class that defines a new, separate suite for the release' do
    suite_path = File.join(root_dir, 'au_ps_v110.rb')
    definition_path = File.expand_path('../../lib/au_ps_inferno/suite/au_ps_suite_definition', __dir__)
    File.write(suite_path, suite_class_source('1.1.0').sub("require_relative 'au_ps_suite_definition'",
                                                           "require '#{definition_path}'"))
    load suite_path

    suite = AUPSTestKit::AUPSV110Suite
    expect(suite.id).to eq('au_ps_v110')
    expect(suite.title).to eq('AU PS 1.1.0 Test Suite')
    expect(suite.fhir_validators[:default].first.igs).to eq(['hl7.fhir.au.ps#1.1.0'])
    expect(suite.groups.map(&:id)).to all(start_with('au_ps_v110-'))
  ensure
    if defined?(AUPSTestKit::AUPSV110Suite)
      AUPSTestKit::AUPSV110Suite.send(:remove_self_from_repository)
      AUPSTestKit.send(:remove_const, :AUPSV110Suite)
    end
  end

  it 'writes a config for the new release that points at its own archive and suite class' do
    write_config_for_new_version!(base_config, old_version: '1.0.0', new_version: '1.1.0',
                                               new_archive_path: 'lib/au_ps_inferno/igs/hl7.fhir.au.ps-1.1.0.tgz')

    config = JSON.parse(File.read(File.join(root_dir, 'inferno_suite_generator.config.1.1.0.json')))
    expect(config['kit']['suite_file']).to eq('lib/au_ps_inferno/suite/au_ps_v110.rb')
    expect(config['ig']).to include('version' => '1.1.0',
                                    'package_archive_path' => 'lib/au_ps_inferno/igs/hl7.fhir.au.ps-1.1.0.tgz',
                                    'cs_version_specific_url' => 'https://hl7.org.au/fhir/ps/1.1.0/CapabilityStatement-au-ps-responder.html')
    expect(base_config['ig']['version']).to eq('1.0.0')
  end

  it 'registers the new suite after the last released one, once' do
    entry_point = File.join(root_dir, 'au_ps_inferno.rb')
    File.write(entry_point, "# comment\nrequire_relative 'au_ps_inferno/suite/au_ps_v100'\n")
    stub_const('ENTRY_POINT_PATH', entry_point)

    2.times { register_suite!('1.1.0') }

    expect(File.readlines(entry_point, chomp: true)).to eq(
      [
        '# comment',
        "require_relative 'au_ps_inferno/suite/au_ps_v100'",
        "require_relative 'au_ps_inferno/suite/au_ps_v110'"
      ]
    )
  end

  it 'treats only releases as released versions' do
    %w[1.0.0 1.1.0-ballot ci-build].each do |key|
      File.write(File.join(root_dir, "inferno_suite_generator.config.#{key}.json"), '{}')
    end

    expect(released_version_keys).to contain_exactly('1.0.0', '1.1.0-ballot')
    expect(newest_released_key).to eq('1.1.0-ballot')
  end
end
