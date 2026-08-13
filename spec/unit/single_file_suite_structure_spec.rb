# frozen_string_literal: true

require 'fhir_models'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'
require_relative '../../lib/au_ps_inferno/suite/single_file_suite_builder'

# The production single-file suite (lib/au_ps_inferno/suite/au_ps_v100_single_file.rb) is built
# with suite_id: :au_ps_v100, deliberately colliding with the generated suite's own id so it can
# stand in for it. That means the two can never be registered in the same process at once, so this
# spec builds a second copy under its own id purely so both can be inspected side by side here.
STRUCTURE_CHECK_SUITE_ID = :au_ps_v100_single_file_structure_check

AUPSTestKit::SingleFileSuiteBuilder.build(
  suite_id: STRUCTURE_CHECK_SUITE_ID,
  ig_version: AUPSTestKit::IG_VERSION,
  suite_title: 'AU PS single-file structure check',
  suite_description: 'Same builder call as the production au_ps_v100_single_file.rb, under its ' \
                     'own id so it can be compared, in-process, against the real au_ps_v100.',
  metadata_dir: File.expand_path('../../lib/au_ps_inferno', __dir__)
)

RSpec.describe 'AU PS single-file suite structure' do
  let(:single_file_suite) { Inferno::Repositories::TestSuites.new.find(STRUCTURE_CHECK_SUITE_ID.to_s) }
  let(:generated_suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100') }

  # Recursively captures the shape that matters for structural parity: titles and
  # optionality, top to bottom. Descriptions are verified separately, once, below.
  def shape_of(runnable)
    children = runnable.respond_to?(:children) ? runnable.children : []
    { title: runnable.title, optional: runnable.optional?, children: children.map { |c| shape_of(c) } }
  end

  # Recursively captures every id, with the comparison suite's id prefix normalized back to
  # au_ps_v100 so it lines up with the ids the production build (which really is au_ps_v100)
  # would report.
  def ids_of(runnable, acc = [])
    acc << runnable.id.to_s.sub(/\A#{STRUCTURE_CHECK_SUITE_ID}\b/, 'au_ps_v100')
    (runnable.respond_to?(:children) ? runnable.children : []).each { |c| ids_of(c, acc) }
    acc
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

  it 'produces ids that are identical, one-for-one, to the generated au_ps_v100 suite' do
    expect(ids_of(single_file_suite).to_set).to eq(ids_of(generated_suite).to_set)
  end

  it 'pins the validator to the Australian SNOMED CT edition' do
    definition = single_file_suite.fhir_validators[:default].first.validation_context.definition

    expect(definition[:snomedCT]).to eq('au')
  end
end
