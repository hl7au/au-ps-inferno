# frozen_string_literal: true

require 'json'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'
require_relative '../support/suite_tree'

# Records the full au_ps_v100 runnable tree (every group and test id, database id, title,
# description, input and output, plus the validator configuration) and fails when any of
# it changes. Sessions are stored against these ids, so a change here breaks existing
# sessions and must be deliberate. Re-record with UPDATE_SUITE_SNAPSHOTS=1.
RSpec.describe 'au_ps_v100 structure snapshot' do
  snapshot_path = File.expand_path('../fixtures/suite_structure/au_ps_v100.json', __dir__)

  it 'matches the recorded runnable tree' do
    suite = Inferno::Repositories::TestSuites.new.find('au_ps_v100')
    actual = SuiteTree.dump_suite(suite)

    File.write(snapshot_path, "#{JSON.pretty_generate(actual)}\n") if ENV['UPDATE_SUITE_SNAPSHOTS'] == '1'

    expect(actual).to eq(JSON.parse(File.read(snapshot_path)))
  end
end
