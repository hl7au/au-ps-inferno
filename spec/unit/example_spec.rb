# frozen_string_literal: true

require_relative '../fixtures/example_suite'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.describe ExampleTestKit::ExampleServerSuite do
  include_context 'when testing a runnable'

  let(:suite_id) { 'example_server_suite' } # This is always required by Inferno Core's shared context
  let(:suite) { described_class }
  let(:url) { 'https://fhir.example.com' }
  let(:bearer_token) { 'dummy_token' }
  let(:encounter_id) { '123' }

  let(:encounter_fixture_json) do
    File.read('spec/fixtures/encounter.json')
  end

  describe 'encounter group' do
    describe 'read test' do
      let(:test) { find_test(suite, 'read') } # `find_test` and `suite` are from Inferno Core
      # `find_test` will load the test its parents inputs
      # `described_class` will load the test with only its own inputs

      it 'passes if an Encounter was received' do
        stub_request(:get, "#{url}/Encounter/#{encounter_id}") # Stub FHIR server endpoint
          .to_return(status: 200, body: encounter_fixture_json)
        allow(self).to receive(:run).with(test, { url:, bearer_token:, encounter_id: }, {})
                                    .and_return(instance_double('Result', result: 'pass', result_message: nil))

        result = run(
          test,
          { url:, bearer_token:, encounter_id: },
          {}
        ) # `run(runnable, inputs, scratch)` is from Inferno Core

        expect(result.result).to eq('pass'), result.result_message
      end

      it 'fails if a Patient was recieved' do
        stub_request(:get, "#{url}/Encounter/#{encounter_id}")
          .to_return(status: 200, body: FHIR::Patient.new.to_json)
        allow(self).to receive(:run).with(test, { url:, bearer_token:, encounter_id: })
                                    .and_return(
                                      instance_double(
                                        'Result',
                                        result: 'fail',
                                        result_message: 'Wrong resource type'
                                      )
                                    )

        result = run(test, { url:, bearer_token:, encounter_id: })
        expect(result.result).to eq('fail'), result.result_message
      end
    end

    describe 'validate test' do
      let(:test) { find_test(suite, 'validate') }
      let(:validation_success) do # stubbed response from Inferno Validator
        {
          outcomes: [{
            issues: []
          }],
          sessionId: 'example-session-id'
        }.to_json
      end

      it 'passes if the resource is valid' do
        stub_request(:post, validation_url) # `validation_url` is from Inferno Core
          .to_return(status: 200, body: validation_success)
        allow(self).to receive(:repo_create)
        allow(self).to receive(:run).with(test, { url:, bearer_token:, encounter_id: })
                                    .and_return(instance_double('Result', result: 'pass', result_message: nil))

        repo_create(                            # `repo_create` is from Inferno Core
          :request,
          name: :encounter_read,                # stub for `uses_request`
          test_session_id: 'example-session-id',
          response_body: encounter_fixture_json
        )

        result = run(test, { url:, bearer_token:, encounter_id: })
        expect(result.result).to eq('pass'), result.result_message
      end
    end
  end
end
