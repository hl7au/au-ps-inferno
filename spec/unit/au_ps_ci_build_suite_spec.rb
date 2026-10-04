# frozen_string_literal: true

require 'json'
require 'open3'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'
# Loaded directly so the spec covers the suite whatever INFERNO_CI_BUILD_SUITES is set to.
require_relative '../../lib/au_ps_inferno/suite/au_ps_ci_build'

RSpec.describe AUPSTestKit::AUPSCIBuildSuite do
  root_dir = File.expand_path('../..', __dir__)
  config = JSON.parse(File.read(File.join(root_dir, 'config.ci-build.json')))

  def all_runnables(runnable)
    [runnable, *runnable.children.flat_map { |child| all_runnables(child) }]
  end

  it 'keeps a fixed suite id whatever the CI build package version' do
    expect(config.dig('ig', 'version')).to eq(described_class::IG_VERSION)
    expect(described_class.id).to eq('au_ps_ci_build')
    expect(described_class::SUITE_VERSION.with(ig_version: '1.1.0-ci-build').suite_id).to eq(:au_ps_ci_build)
  end

  it 'validates against the #current package id, never a file path' do
    igs = described_class.fhir_validators[:default].first.igs

    expect(igs).to eq(['hl7.fhir.au.ps#current'])
    expect(igs.first).not_to include('/')
  end

  it 'says it tracks the CI build and that sessions may stop rendering after a regeneration' do
    expect(described_class.title).to eq("AU PS #{described_class::IG_VERSION} Test Suite (tracks the CI build)")
    expect(described_class.description).to include('tracks the CI build')
      .and include('https://build.fhir.org/ig/hl7au/au-fhir-ps/')
      .and include('sessions started before it may stop rendering')
  end

  it 'reads the ci-build metadata and validates the bundle against the CI profile version' do
    test = all_runnables(described_class).find { |runnable| runnable < AUPSTestKit::BasicTest }.new(scratch: {})

    expect(test.metadata_manager.metadata_yaml_path)
      .to eq(File.join(root_dir, 'lib/au_ps_inferno/generated/ci-build/metadata.yaml'))
    expect(test.au_ps_ig_version).to eq(described_class::IG_VERSION)
  end

  it 'validates against the unversioned AU PS Bundle canonical, since #current can move ahead of the suite' do
    test = all_runnables(described_class).find { |runnable| runnable < AUPSTestKit::BasicTest }.new(scratch: {})

    expect(test.au_ps_profile('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle'))
      .to eq('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle')
  end

  it 'coexists with au_ps_v100 without sharing an id or database id' do
    released = Inferno::Repositories::TestSuites.new.find('au_ps_v100')
    ids = ->(suite) { all_runnables(suite).flat_map { |runnable| [runnable.id.to_s, runnable.database_id.to_s] } }

    expect(ids.call(described_class) & ids.call(released)).to be_empty
  end

  describe AUPSTestKit::CIBuildSuites do
    let(:suite) { AUPSTestKit::AUPSCIBuildSuite }

    it 'is enabled only when INFERNO_CI_BUILD_SUITES is exactly "true"' do
      expect(described_class.enabled?('INFERNO_CI_BUILD_SUITES' => 'true')).to be(true)
      %w[false TRUE 1 yes].each do |value|
        expect(described_class.enabled?('INFERNO_CI_BUILD_SUITES' => value)).to be(false)
      end
      expect(described_class.enabled?({})).to be(false)
    end

    # Boots the kit the way a deployment does, once without and once with the flag.
    it 'registers the CI build suite with the app only when the flag is set' do
      listed = lambda do |env|
        output, status = Open3.capture2e(env.merge('APP_ENV' => 'test'), 'bundle', 'exec', 'inferno', 'suites',
                                         chdir: root_dir)
        raise output unless status.success?

        output.include?(suite.id.to_s)
      end

      expect(listed.call('INFERNO_CI_BUILD_SUITES' => nil)).to be(false)
      expect(listed.call('INFERNO_CI_BUILD_SUITES' => 'true')).to be(true)
    end
  end
end
