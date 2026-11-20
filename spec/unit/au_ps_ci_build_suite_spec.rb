# frozen_string_literal: true

require 'json'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'
require_relative '../../lib/au_ps_inferno/generator/ci_build_suite_template'

# The generated suite lives only on the ci-build branch (and in the refresh job that maintains
# it); master carries the tooling without it, so these examples skip there.
suite_generated = File.exist?(AUPSTestKit::CIBuildSuites::SUITE_FILE)
suite_absent = 'the ci-build suite is not generated in this tree; it lives on the ci-build branch'
# Loaded directly so the spec covers the suite whatever INFERNO_CI_BUILD_SUITES is set to.
require AUPSTestKit::CIBuildSuites::SUITE_FILE if suite_generated

RSpec.describe 'AU PS CI build suite', skip: (suite_absent unless suite_generated) do
  root_dir = File.expand_path('../..', __dir__)
  config = JSON.parse(File.read(File.join(root_dir, 'config.ci-build.json')))

  let(:suite) { AUPSTestKit::AUPSCIBuildSuite }

  def all_runnables(runnable)
    [runnable, *runnable.children.flat_map { |child| all_runnables(child) }]
  end

  it 'is the template generated for the package version recorded in config.ci-build.json' do
    expect(File.read(AUPSTestKit::CIBuildSuites::SUITE_FILE))
      .to eq(AUPSTestKit::CIBuildSuiteTemplate.source(config.dig('ig', 'version')))
  end

  it 'keeps a fixed suite id whatever the CI build package version' do
    expect(config.dig('ig', 'version')).to eq(suite::IG_VERSION)
    expect(suite.id).to eq('au_ps_ci_build')
    expect(suite::SUITE_VERSION.with(ig_version: '1.1.0-ci-build').suite_id).to eq(:au_ps_ci_build)
  end

  it 'validates against the #current package id, never a file path' do
    igs = suite.fhir_validators[:default].first.igs

    expect(igs).to eq(['hl7.fhir.au.ps#current'])
    expect(igs.first).not_to include('/')
  end

  it 'says it tracks the CI build and that sessions may stop rendering after a regeneration' do
    expect(suite.title).to eq("AU PS #{suite::IG_VERSION} Test Suite (tracks the CI build)")
    expect(suite.description).to include('tracks the CI build')
      .and include('https://build.fhir.org/ig/hl7au/au-fhir-ps/')
      .and include('sessions started before it may stop rendering')
  end

  it 'reads the ci-build metadata and validates the bundle against the CI profile version' do
    test = all_runnables(suite).find { |runnable| runnable < AUPSTestKit::BasicTest }.new(scratch: {})

    expect(test.metadata_manager.metadata_yaml_path)
      .to eq(File.join(root_dir, 'lib/au_ps_inferno/generated/ci-build/metadata.yaml'))
    expect(test.au_ps_ig_version).to eq(suite::IG_VERSION)
  end

  it 'validates against the unversioned AU PS Bundle canonical, since #current can move ahead of the suite' do
    test = all_runnables(suite).find { |runnable| runnable < AUPSTestKit::BasicTest }.new(scratch: {})

    expect(test.au_ps_profile('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle'))
      .to eq('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle')
  end

  it 'coexists with au_ps_v100 without sharing an id or database id' do
    released = Inferno::Repositories::TestSuites.new.find('au_ps_v100')
    ids = ->(runnable) { all_runnables(runnable).flat_map { |child| [child.id.to_s, child.database_id.to_s] } }

    expect(ids.call(suite) & ids.call(released)).to be_empty
  end
end
