# frozen_string_literal: true

require_relative 'support/bundle_cases'
require_relative 'support/mocked_validator'
require_relative 'support/mocked_summary_operation'
require_relative 'support/run_full_group'
require_relative 'support/baseline_support'

RSpec.describe 'suite_generate_au_ps_using_ips_summary_validation_tests regression' do
  include_context 'when testing a runnable'
  include MockedValidatorSupport
  include MockedSummaryOperationSupport
  include RunFullGroupSupport
  include BaselineSupport

  let(:suite_id) { RunFullGroupSupport::AU_PS_SUITE_ID }
  let(:group_id) { 'suite_generate_au_ps_using_ips_summary_validation_tests' }
  let(:base_url) { 'https://example.com/fhir' }
  let(:profile) { 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle' }

  before { stub_mocked_fhir_validator! }

  RegressionBundleCases::ALL.each do |test_case|
    it "matches the recorded baseline for #{test_case[:name]}" do
      # patient_id only needs to be a stable, unique value to match against --
      # it never has to correspond to a Patient actually present in the
      # fixture, so the bundle case name is reused as a convenient id.
      patient_id = test_case[:name]

      stub_summary_operation!(
        base_url: base_url,
        patient_id: patient_id,
        profile: profile,
        fixture_path: RegressionBundleCases.fixture_path(test_case[:file])
      )

      results = run_group_with_bundle(
        top_level_group(group_id),
        nil,
        extra_inputs: {
          url: base_url,
          patient_id: patient_id,
          profile: profile,
          validate_against: %w[au_ps_bundle ips_bundle]
        }
      )

      assert_or_update_baseline(group_id, test_case[:name], results)
    end
  end
end
