# frozen_string_literal: true

require 'fhir_models'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'

RSpec.describe 'AU PS suite structure' do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100') }

  def bundle_validation_group(top_level_group_id_fragment)
    group = suite.groups.find { |g| g.id.to_s.include?(top_level_group_id_fragment) }
    group.children.find { |c| c.id.to_s.include?('bundle_validation') }
  end

  it 'loads all four top-level groups' do
    expect(suite.groups.length).to eq(4)
  end

  it 'starts the instance Bundle Validation group with the load test' do
    titles = bundle_validation_group('au_ps_bundle_instance').children.map(&:title)
    expect(titles).to eq(
      [
        'Load the provided AU PS Bundle',
        'Bundle is valid against AU PS Bundle',
        'Bundle is valid against IPS Bundle'
      ]
    )
  end

  it 'starts the retrieve Bundle Validation group with the retrieval test' do
    titles = bundle_validation_group('retrieve_au_ps_bundle_validation_tests').children.map(&:title)
    expect(titles).to eq(
      [
        'Retrieve AU PS Bundle from the FHIR server',
        'Retrieved Bundle is valid against AU PS Bundle profile',
        'Retrieved Bundle is valid against IPS Bundle profile'
      ]
    )
  end

  it 'starts the $summary Bundle Validation group with the generate test' do
    titles = bundle_validation_group('generate_au_ps_using_ips_summary').children.map(&:title)
    expect(titles).to eq(
      [
        'Generate AU PS Bundle using the IPS $summary operation',
        'Generated Bundle is valid against AU PS Bundle profile',
        'Generated Bundle is valid against IPS Bundle profile'
      ]
    )
  end
end
