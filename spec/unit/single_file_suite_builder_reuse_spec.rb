# frozen_string_literal: true

require 'fhir_models'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'

# Proves SingleFileSuiteBuilder.build can be called a second time, with a different
# suite id/ig_version, and produce a fully independent suite. Reuses
# au_ps_v100_single_file's own metadata_dir since no second real AU PS release ships
# in this repo -- the point being demonstrated is the builder call producing an
# isolated suite, not the metadata content, which is intentionally identical.
SECOND_BUILD_SUITE_ID = :au_ps_single_file_builder_reuse_demo
SECOND_BUILD_IG_VERSION = '9.9.9-reuse-demo'

AUPSTestKit::SingleFileSuiteBuilder.build(
  suite_id: SECOND_BUILD_SUITE_ID,
  ig_version: SECOND_BUILD_IG_VERSION,
  suite_title: 'AU PS Single-File Builder Reuse Demo',
  suite_description: 'Second call to the same builder, proving it is safe to call more than once.',
  metadata_dir: File.expand_path('../../lib/au_ps_inferno', __dir__)
)

RSpec.describe 'SingleFileSuiteBuilder: a second build() call is fully independent' do
  include_context 'when testing a runnable'

  let(:suite_id) { SECOND_BUILD_SUITE_ID.to_s }
  let(:suite) { Inferno::Repositories::TestSuites.new.find(SECOND_BUILD_SUITE_ID.to_s) }
  let(:original_suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100_single_file') }

  it 'registers independently from au_ps_v100_single_file' do
    expect(suite).to be_present
    expect(original_suite).to be_present
    expect(suite.id).not_to eq(original_suite.id)
  end

  it 'builds the same group structure as any other AU PS single-file suite' do
    expect(suite.groups.map(&:title)).to contain_exactly(*original_suite.groups.map(&:title))
  end

  it "pins its own fhir_resource_validator to the ig_version it was built with, not au_ps_v100_single_file's" do
    definition = suite.fhir_validators[:default].first.validation_context.definition
    original_definition = original_suite.fhir_validators[:default].first.validation_context.definition

    expect(definition[:igs]).to include(a_string_ending_with(SECOND_BUILD_IG_VERSION))
    expect(original_definition[:igs]).to all(satisfy { |ig| !ig.end_with?(SECOND_BUILD_IG_VERSION) })
  end

  it "validates the AU PS Bundle profile at its own ig_version, not the other suite's" do
    instance_group = suite.groups.find { |g| g.title == 'AU PS Bundle Instance' }
    bundle_validation_group = instance_group.children.find { |c| c.title == 'Bundle Validation' }
    bundle_valid_test = bundle_validation_group.children.find { |c| c.title == 'Bundle is valid against AU PS Bundle' }

    expect_any_instance_of(bundle_valid_test).to receive(:validate_bundle_wrapper)
      .with("http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|#{SECOND_BUILD_IG_VERSION}")

    run(bundle_valid_test, { validate_against: ['au_ps_bundle'] }, { bundle_ips_resource_instance: FHIR::Bundle.new })
  end
end
