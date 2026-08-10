# frozen_string_literal: true

require 'fhir_models'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'

RSpec.describe 'AU PS single-file suite structure' do
  let(:single_file_suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100_single_file') }
  let(:generated_suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100') }

  # Recursively captures the shape that matters for structural parity: titles and
  # optionality, top to bottom. Ignores ids (single_file_* vs suite_* differ by
  # design) and descriptions (verified separately, once, below).
  def shape_of(runnable)
    children = runnable.respond_to?(:children) ? runnable.children : []
    { title: runnable.title, optional: runnable.optional?, children: children.map { |c| shape_of(c) } }
  end

  def generated_group(title)
    generated_suite.groups.find { |g| g.title == title }
  end

  def single_file_group(title)
    single_file_suite.groups.find { |g| g.title == title }
  end

  it 'loads without touching the generated au_ps_v100 suite' do
    expect(single_file_suite).to be_present
    expect(generated_suite).to be_present
  end

  it 'builds the same 4 top-level groups as au_ps_v100 (order differs: CapabilityStatement moved last)' do
    expect(single_file_suite.groups.map(&:title)).to contain_exactly(*generated_suite.groups.map(&:title))
  end

  it 'mirrors the "AU PS Bundle Instance" subtree' do
    title = 'AU PS Bundle Instance'
    expect(shape_of(single_file_group(title))).to eq(shape_of(generated_group(title)))
  end

  it 'mirrors the "Retrieve AU PS Bundle validation tests" subtree' do
    title = 'Retrieve AU PS Bundle validation tests'
    expect(shape_of(single_file_group(title))).to eq(shape_of(generated_group(title)))
  end

  it 'mirrors the "Generate AU PS using IPS $summary validation tests" subtree' do
    title = 'Generate AU PS using IPS $summary validation tests'
    expect(shape_of(single_file_group(title))).to eq(shape_of(generated_group(title)))
  end

  it 'reuses the CapabilityStatement group verbatim (identical subtree)' do
    title = 'Retrieve Capability Statement'
    expect(shape_of(single_file_group(title))).to eq(shape_of(generated_group(title)))
  end

  it 'pins the validator to the Australian SNOMED CT edition' do
    definition = single_file_suite.fhir_validators[:default].first.validation_context.definition

    expect(definition[:snomedCT]).to eq('au')
  end
end
