# frozen_string_literal: true

require 'fhir_models'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'

RSpec.describe 'AU PS suite structure' do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100') }

  def top_level_group(id_fragment)
    suite.groups.find { |g| g.id.to_s.include?(id_fragment) }
  end

  it 'loads a flat list of thirteen top-level groups, none nesting another group' do
    expect(suite.groups.length).to eq(13)
    expect(suite.groups).to all(satisfy { |g| g.groups.empty? })
  end

  it 'pins the validator to the Australian SNOMED CT edition' do
    definition = suite.fhir_validators[:default].first.validation_context.definition

    expect(definition[:snomedCT]).to eq('au')
  end

  it 'runs Bundle Acquisition first, with one test per acquisition method' do
    group = top_level_group('suite_bundle_acquisition')

    expect(suite.groups.first).to eq(group)
    expect(group.children.map(&:title)).to eq(
      [
        'Bundle acquired from a pasted resource',
        'Bundle acquired from a Bundle URL',
        'Bundle acquired via Bundle ID',
        'Bundle acquired via Patient ID ($summary)',
        'Bundle acquired via Patient identifier ($summary)'
      ]
    )
  end

  it 'runs the Capability Statement group right after Bundle Acquisition' do
    expect(suite.groups.second.id.to_s).to include('au_ps_retrieve_cs_group_100preview')
  end

  it 'has a single flat Bundle Validation group reading the shared acquired Bundle' do
    group = top_level_group('suite_au_ps_bundle_instance_bundle_validation')

    expect(group.children.map(&:title)).to eq(
      [
        'Bundle is valid against AU PS Bundle',
        'Bundle is valid against IPS Bundle'
      ]
    )
  end
end
