# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require 'yaml'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../../lib/au_ps_inferno/release/suite_version_builder'

# Exercises the real hl7.fhir.au.ps 1.0.0 package archive already committed at
# lib/au_ps_inferno/igs/1.0.0.tgz -- the same fixture `make generate` uses -- through the new
# release pipeline's extraction path, end to end into a throwaway tmp folder.
RSpec.describe Release::SuiteVersionBuilder do
  include_context 'when testing a runnable'

  # A version distinct from any real published version, so the suite id this test registers
  # (au_ps_release_v100_buildertest) can never collide with one `make new_release` produced.
  let(:version) { '1.0.0-buildertest' }
  let(:package_archive_path) { File.expand_path('../../../lib/au_ps_inferno/igs/1.0.0.tgz', __dir__) }
  let(:generated_root) { Dir.mktmpdir }
  let(:output_dir) do
    described_class.new(version: version, package_archive_path: package_archive_path,
                         generated_root: generated_root).build!
  end

  after do
    Registry.register(:config_keeper, nil)
    FileUtils.remove_entry(generated_root) if Dir.exist?(generated_root)
  end

  it 'writes metadata.yaml with the core IG metadata' do
    metadata = YAML.safe_load_file(File.join(output_dir, 'metadata.yaml'),
                                    permitted_classes: [Symbol], aliases: true)

    expect(metadata[:ig_id]).to eq('hl7.fhir.au.ps')
    expect(metadata[:groups]).to be_an(Array).and be_present
  end

  it 'writes composition_metadata.yaml with composition section metadata' do
    metadata = YAML.safe_load_file(File.join(output_dir, 'composition_metadata.yaml'),
                                    permitted_classes: [Symbol], aliases: true)

    expect(metadata[:composition_sections]).to be_an(Array).and be_present
    expect(metadata[:subject]).to be_present
  end

  it 'writes a suite.rb that registers an independent suite pinned to its own ig_version' do
    load File.join(output_dir, 'suite.rb')

    suite_id = Release::VersionNaming.suite_id(version).to_s
    suite = Inferno::Repositories::TestSuites.new.find(suite_id)
    expect(suite).to be_present

    definition = suite.fhir_validators[:default].first.validation_context.definition
    expect(definition[:igs]).to include(a_string_ending_with(version))
  end
end
