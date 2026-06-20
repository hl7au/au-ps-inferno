# frozen_string_literal: true

require_relative '../spec_helper'
require 'au_ps_inferno'

# Runs the generated AU PS Bundle Instance group against a real AU PS example bundle
# (Bundle-aups-basicsummary.json from the AU PS IG) and asserts that the reworded,
# status-specific conformance messages are produced and that the old wording is gone.
RSpec.describe 'AU PS conformance messages against a real example bundle' do # rubocop:disable Metrics/BlockLength
  let(:suite_id) { 'suite_100preview' }
  let(:suite) { Inferno::Repositories::TestSuites.new.find(suite_id) }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { Inferno::Repositories::TestSessions.new.create(test_suite_id: suite_id) }
  let(:bundle_json) { File.read(File.join(__dir__, '..', 'fixtures', 'bundles', 'aups-basicsummary.json')) }

  def run(runnable, inputs = {}, scratch = {})
    test_run = Inferno::Repositories::TestRuns.new.create({ test_session_id: test_session.id }.merge(runnable.reference_hash))
    inputs.each do |original_name, value|
      name = runnable.config.input_name(original_name).presence || original_name
      session_data_repo.save(test_session_id: test_session.id, name:, value:,
                             type: runnable.available_inputs[name.to_sym]&.type)
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable, scratch)
  end

  def find_runnable(runnable, suffix)
    return runnable if runnable.id.to_s.end_with?(suffix)

    runnable.children.each do |child|
      found = find_runnable(child, suffix)
      return found unless found.nil?
    end
    nil
  end

  # All message strings produced across the whole session, regardless of status.
  def all_messages
    results_repo.current_results_for_test_session(test_session.id)
                .flat_map(&:messages)
                .map(&:message)
  end

  before do
    group = find_runnable(suite, 'au_ps_bundle_instance')
    run(group, { bundle_resource: bundle_json })
  end

  it 'registers the renamed groups with the new titles' do
    expect(find_runnable(suite, 'au_ps_bundle_conformance_tests').title).to eq('AU PS Bundle Conformance Tests')
    expect(find_runnable(suite, 'au_ps_composition_conformance_tests').title)
      .to eq('AU PS Composition Conformance Tests')
    expect(find_runnable(suite, 'patient_summary_bundle_validation_tests').title)
      .to eq('Patient Summary Bundle Validation Tests')
  end

  it 'emits the new status-specific Bundle Must Support messages' do
    msgs = all_messages
    expect(msgs).to include(a_string_including('All mandatory Must Support elements are correctly populated'))
    expect(msgs).to include(a_string_including('The test data included the following resource types as an entry'))
  end

  it 'uses canonical section names and the new section heading' do
    msgs = all_messages
    expect(msgs).to include(a_string_including('Patient Summary Problems Section (11450-4)'))
    expect(msgs).to include(
      a_string_including('Must Support elements are correctly populated in the Patient Summary Problems Section')
    )
  end

  it 'no longer emits any of the old/misleading wording' do
    joined = all_messages.join("\n")
    expect(joined).not_to include('List mandatory Must Support elements populated and missing')
    expect(joined).not_to include('Some of the elements are not populated. See the list of populated elements')
    expect(joined).not_to include('that would be validated:')
    expect(joined).not_to include('List any entry resources by type')
  end

  it 'passes the Bundle and Composition Must Support conformance tests for a valid summary' do
    results = results_repo.current_results_for_test_session(test_session.id)
    %w[bundle_must_support_populated composition_mandatory_ms_populated].each do |suffix|
      result = results.find { |r| r.test_id.to_s.end_with?(suffix) }
      expect(result).not_to be_nil, "no result for #{suffix}"
      expect(result.result).to eq('pass'), "#{suffix} => #{result.result}: #{result.result_message}"
    end
  end
end

# Same suite, but the bundle is deliberately broken to exercise the new error wording.
RSpec.describe 'AU PS conformance error wording against a broken bundle' do
  let(:suite_id) { 'suite_100preview' }
  let(:suite) { Inferno::Repositories::TestSuites.new.find(suite_id) }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { Inferno::Repositories::TestSessions.new.create(test_suite_id: suite_id) }

  # Drop a mandatory bundle Must Support element (timestamp) so the Bundle MS test must fail.
  let(:broken_bundle_json) do
    data = JSON.parse(File.read(File.join(__dir__, '..', 'fixtures', 'bundles', 'aups-basicsummary.json')))
    data.delete('timestamp')
    JSON.generate(data)
  end

  def run(runnable, inputs = {}, scratch = {})
    test_run = Inferno::Repositories::TestRuns.new.create({ test_session_id: test_session.id }.merge(runnable.reference_hash))
    inputs.each do |original_name, value|
      name = runnable.config.input_name(original_name).presence || original_name
      session_data_repo.save(test_session_id: test_session.id, name:, value:,
                             type: runnable.available_inputs[name.to_sym]&.type)
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable, scratch)
  end

  def find_runnable(runnable, suffix)
    return runnable if runnable.id.to_s.end_with?(suffix)

    runnable.children.each do |child|
      found = find_runnable(child, suffix)
      return found unless found.nil?
    end
    nil
  end

  before do
    run(find_runnable(suite, 'au_ps_bundle_instance'), { bundle_resource: broken_bundle_json })
  end

  it 'fails the Bundle MS test with the new affirmative error message and wording' do
    results = results_repo.current_results_for_test_session(test_session.id)
    result = results.find { |r| r.test_id.to_s.end_with?('bundle_must_support_populated') }

    expect(result.result).to eq('fail')
    expect(result.result_message).to include('Mandatory Must Support elements are not populated')
    expect(result.messages.map(&:message))
      .to include(a_string_including('At least one mandatory Must Support element is not populated'))
  end
end
