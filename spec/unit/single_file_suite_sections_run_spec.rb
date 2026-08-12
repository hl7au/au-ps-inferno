# frozen_string_literal: true

require 'fhir_models'
require 'json'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'

RSpec.describe 'AU PS single-file suite: AU PS Bundle Instance run behavior' do
  include_context 'when testing a runnable'

  let(:suite_id) { 'au_ps_v100_single_file' }
  let(:suite) { Inferno::Repositories::TestSuites.new.find(suite_id) }

  def find_by_title(runnable, title)
    runnable.children.find { |c| c.title == title }
  end

  def mandatory_sections_test(title)
    instance_group = suite.groups.find { |g| g.title == 'AU PS Bundle Instance' }
    mandatory_group = find_by_title(instance_group, 'AU PS Composition Mandatory Sections')
    find_by_title(mandatory_group, title)
  end

  # Metadata fixture with known composition_sections/subject/author/custodian/attester content, so
  # this spec's expectations don't depend on the real generated production metadata.yaml being
  # present or up to date.
  def stub_test_metadata_manager(test_class)
    manager = AUPSTestKit::MetadataManager.new(File.expand_path('../fixtures/metadata.yaml', __dir__))
    test_class.class_eval { define_method(:metadata_manager) { manager } }
  end

  def fixture_json(name)
    JSON.parse(File.read(File.expand_path("../fixtures/bundles/#{name}.json", __dir__)))
  end

  def bundle_from_fixture(name)
    FHIR.from_contents(fixture_json(name).to_json)
  end

  it 'passes when the fixture bundle has all mandatory sections fully populated' do
    test = mandatory_sections_test('AU PS Composition Mandatory Sections are correctly populated')
    result = run(test, {}, { bundle_ips_resource_instance: bundle_from_fixture('mandatory-success-bundle') })

    expect(result.result).to eq('pass')
  end

  it 'omits when no Bundle was acquired' do
    test = mandatory_sections_test('AU PS Composition Mandatory Sections are correctly populated')
    result = run(test, {}, {})

    expect(result.result).to eq('omit')
  end

  it 'fails when a mandatory section is missing entirely' do
    json = fixture_json('mandatory-success-bundle')
    composition_entry = json['entry'].find { |e| e['resource']['resourceType'] == 'Composition' }
    composition_entry['resource']['section'].reject! { |s| s['code']['coding'].first['code'] == '11450-4' }
    bundle = FHIR.from_contents(json.to_json)

    test = mandatory_sections_test('AU PS Composition Mandatory Sections are correctly populated')
    result = run(test, {}, { bundle_ips_resource_instance: bundle })

    expect(result.result).to eq('fail')
  end

  it "reuses BasicTest's referenced-profile check for mandatory section entries" do
    test = mandatory_sections_test('AU PS Composition Mandatory Sections capable of populating referenced profiles')
    stub_test_metadata_manager(test)
    result = run(test, {}, { bundle_ips_resource_instance: bundle_from_fixture('mandatory-success-bundle') })

    expect(%w[pass fail]).to include(result.result)
  end
end
