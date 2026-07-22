# frozen_string_literal: true

require 'webmock/rspec'

# Stubs the two HTTP calls the FHIR validator DSL makes
# (Inferno::DSL::FHIRResourceValidation::Validator and
# AUPSTestKit::ValidatorHelpers), so regression runs never touch a real
# validator and always see a "no issues" outcome. Validator content is out of
# scope for these regression tests: they exist to catch regressions in the
# Inferno suite's own logic (parsing, section/MS extraction, composition
# checks), not to judge whether a bundle is actually IG-conformant.
module MockedValidatorSupport
  def validator_base_url
    ENV.fetch('FHIR_RESOURCE_VALIDATOR_URL')
  end

  def stub_mocked_fhir_validator!
    stub_validator_version!
    stub_validator_validate!
  end

  private

  def stub_validator_version!
    stub_request(:get, "#{validator_base_url}/validator/version")
      .to_return(
        status: 200,
        body: { validatorVersion: 'mocked', validatorWrapperVersion: 'mocked' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_validator_validate!
    stub_request(:post, "#{validator_base_url}/validate")
      .to_return(
        status: 200,
        body: { sessionId: 'mocked-validator-session', outcomes: [{ issues: [] }] }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
