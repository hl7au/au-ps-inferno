# frozen_string_literal: true

require_relative 'support/bundle_cases'
require_relative 'support/mocked_validator'
require_relative 'support/run_full_group'
require_relative 'support/baseline_support'

RSpec.describe 'suite_au_ps_bundle_instance regression' do
  include_context 'when testing a runnable'
  include MockedValidatorSupport
  include RunFullGroupSupport
  include BaselineSupport

  let(:suite_id) { RunFullGroupSupport::AU_PS_SUITE_ID }
  let(:group_id) { 'suite_au_ps_bundle_instance' }

  before { stub_mocked_fhir_validator! }

  RegressionBundleCases::ALL.each do |test_case|
    it "matches the recorded baseline for #{test_case[:name]}" do
      bundle_json = File.read(RegressionBundleCases.fixture_path(test_case[:file]))

      results = run_group_with_bundle(
        top_level_group(group_id),
        bundle_json,
        extra_inputs: { validate_against: %w[au_ps_bundle ips_bundle] }
      )

      assert_or_update_baseline(group_id, test_case[:name], results)
    end
  end
end
