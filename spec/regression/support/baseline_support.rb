# frozen_string_literal: true

require 'fileutils'
require 'json'

# Compares a `{ test_id => { result, result_message } }` map produced by
# RunFullGroupSupport#run_group_with_bundle against a committed baseline JSON
# file, one per (group, bundle case) pair. Mirrors the UPDATE_SNAPSHOTS=1
# convention already used by spec/integration/suite_100ballot_snapshots_spec.rb,
# but for structured per-test results instead of raw CLI text.
module BaselineSupport
  UPDATE_BASELINE = ENV['UPDATE_BASELINE'] == '1'

  def baseline_dir_for(group_id)
    File.expand_path("../../fixtures/baselines/#{group_id}", __dir__)
  end

  def baseline_path_for(group_id, case_name)
    File.join(baseline_dir_for(group_id), "#{case_name}.json")
  end

  def assert_or_update_baseline(group_id, case_name, results_by_test_id)
    baseline_file = baseline_path_for(group_id, case_name)
    content = "#{JSON.pretty_generate(results_by_test_id.sort.to_h)}\n"

    return write_baseline(group_id, baseline_file, content) if UPDATE_BASELINE

    unless File.exist?(baseline_file)
      raise "Baseline not found: #{baseline_file}. Run with UPDATE_BASELINE=1 to create it."
    end

    expect(content).to eq(File.read(baseline_file))
  end

  private

  def write_baseline(group_id, baseline_file, content)
    FileUtils.mkdir_p(baseline_dir_for(group_id))
    File.write(baseline_file, content)
  end
end
