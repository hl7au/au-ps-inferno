# frozen_string_literal: true

require 'fhir_models'
require 'json'

require_relative '../../../lib/au_ps_inferno'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

# Runs one of the real, registered AU PS group trees end to end (acquisition
# through composition checks) and reduces the persisted results down to a
# plain `{ test_id => { "result" => ..., "result_message" => ... } }` map,
# suitable for comparing against a committed baseline fixture.
#
# Relies on `include_context 'when testing a runnable'` (from inferno_core)
# already being included by the spec for `run`/`test_session`.
module RunFullGroupSupport
  AU_PS_SUITE_ID = 'au_ps_v100'

  # `group from: :some_id` creates a fresh subclass parented under the suite,
  # with its id re-namespaced as "#{suite.id}-#{base_id}". The originally
  # declared group class stays around too, but orphaned (parent nil), unable
  # to resolve the suite's `fhir_resource_validator` config. We must run the
  # suite-attached copy, found here by reconstructing its namespaced id.
  def top_level_group(base_id)
    suite = Inferno::Repositories::TestSuites.new.find(AU_PS_SUITE_ID)
    find_group_by_id(suite, "#{suite.id}-#{base_id}") ||
      raise("No top-level group '#{base_id}' found under suite '#{AU_PS_SUITE_ID}'")
  end

  def run_group_with_bundle(group_class, bundle_json, extra_inputs: {})
    inputs = extra_inputs.dup
    inputs[:bundle_resource] = bundle_json if bundle_json

    run(group_class, inputs)

    results_by_test_id(test_session.id)
  end

  private

  def find_group_by_id(suite, full_id)
    suite.groups.find { |candidate| candidate.id.to_s == full_id }
  end

  def results_by_test_id(test_session_id)
    results = Inferno::Repositories::Results.new.current_results_for_test_session(test_session_id)

    results.select { |result| result.test_id.present? }.to_h do |result|
      [result.test_id, { 'result' => result.result, 'result_message' => result.result_message }]
    end
  end
end
