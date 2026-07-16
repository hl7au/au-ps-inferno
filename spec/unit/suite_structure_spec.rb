# frozen_string_literal: true

require 'fhir_models'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'

RSpec.describe 'AU PS suite structure' do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100') }

  def top_level_group(id_fragment)
    suite.groups.find { |g| g.id.to_s.include?(id_fragment) }
  end

  def bundle_validation_group(top_level_group_id_fragment)
    top_level_group(top_level_group_id_fragment).children.find { |c| c.id.to_s.end_with?('_bundle_validation') }
  end

  it 'loads all four top-level groups' do
    expect(suite.groups.length).to eq(4)
  end

  it 'starts the instance group with the load test, followed by Bundle Validation' do
    group = top_level_group('au_ps_bundle_instance')
    expect(group.children.first.title).to eq('Provide AU PS Bundle')
    expect(group.children.first.children.map(&:title)).to eq(['Load the provided AU PS Bundle'])
    expect(bundle_validation_group('au_ps_bundle_instance').children.map(&:title)).to eq(
      [
        'Bundle is valid against AU PS Bundle',
        'Bundle is valid against IPS Bundle'
      ]
    )
  end

  it 'starts the retrieve group with the retrieval test, followed by Bundle Validation' do
    group = top_level_group('retrieve_au_ps_bundle_validation_tests')
    expect(group.children.first.title).to eq('Retrieve AU PS Bundle')
    expect(group.children.first.children.map(&:title)).to eq(['Retrieve AU PS Bundle from the FHIR server'])
    expect(bundle_validation_group('retrieve_au_ps_bundle_validation_tests').children.map(&:title)).to eq(
      [
        'Retrieved Bundle is valid against AU PS Bundle profile',
        'Retrieved Bundle is valid against IPS Bundle profile'
      ]
    )
  end

  it 'starts the $summary group with the generate test, followed by Bundle Validation' do
    group = top_level_group('generate_au_ps_using_ips_summary')
    expect(group.children.first.title).to eq('Generate AU PS Bundle using $summary')
    expect(group.children.first.children.map(&:title))
      .to eq(['Generate AU PS Bundle using the IPS $summary operation'])
    expect(bundle_validation_group('generate_au_ps_using_ips_summary').children.map(&:title)).to eq(
      [
        'Generated Bundle is valid against AU PS Bundle profile',
        'Generated Bundle is valid against IPS Bundle profile'
      ]
    )
  end
end
