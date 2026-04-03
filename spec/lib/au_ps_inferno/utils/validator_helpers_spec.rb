# frozen_string_literal: true

require_relative '../../../support/validator_helpers_host'

# rubocop:disable Metrics/BlockLength -- example groups map 1:1 to branches under test
RSpec.describe ValidatorHelpers do
  let(:base_url) { 'http://validator.test' }
  let(:version_url) { "#{base_url}/validator/version" }
  let(:host) { ValidatorHelpersHost.new }

  around do |example|
    previous = ENV.fetch('FHIR_RESOURCE_VALIDATOR_URL', nil)
    ENV['FHIR_RESOURCE_VALIDATOR_URL'] = base_url
    example.run
    if previous.nil?
      ENV.delete('FHIR_RESOURCE_VALIDATOR_URL')
    else
      ENV['FHIR_RESOURCE_VALIDATOR_URL'] = previous
    end
  end

  describe '#show_validator_version' do
    it 'logs inability to fetch when the HTTP layer returns no body' do
      allow(host).to receive(:fetch_validator_version).and_return(nil)

      host.show_validator_version

      expect(host.warning_messages.first).to include('Unable to fetch validator version from')
      expect(host.info_messages).to eq(['Unable to fetch validator version'])
    end

    it 'logs versions from a valid validator response' do
      stub_request(:get, version_url).to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: { validatorVersion: '1.2.3', validatorWrapperVersion: '4.5.6' }.to_json
      )

      host.show_validator_version

      expect(host.info_messages.last).to eq(
        'Using validator version 1.2.3 and validator wrapper version 4.5.6'
      )
      expect(host.scratch[:validator_version]).to eq('1.2.3')
      expect(host.scratch[:validator_wrapper_version]).to eq('4.5.6')
    end

    it 'uses Unknown when version fields are null' do
      stub_request(:get, version_url).to_return(
        status: 200,
        body: { validatorVersion: nil, validatorWrapperVersion: 'w' }.to_json
      )

      host.show_validator_version

      expect(host.info_messages.last).to include('Unknown')
      expect(host.info_messages.last).to include('w')
    end

    it 'only fetches once when scratch is already populated' do
      stub_request(:get, version_url).to_return(
        status: 200,
        body: { validatorVersion: 'a', validatorWrapperVersion: 'b' }.to_json
      )

      host.show_validator_version
      host.show_validator_version

      expect(a_request(:get, version_url)).to have_been_made.once
    end
  end

  describe '#fetch_and_cache_versions (private)' do
    it 'warns when the response body is nil' do
      allow(host).to receive(:fetch_validator_version).with(base_url).and_return(nil)

      result = host.send(:fetch_and_cache_versions)

      expect(result).to be_nil
      expect(host.warning_messages.first).to include('Unable to fetch validator version')
      expect(host.warning_messages.first).to include(base_url)
    end

    it 'warns when JSON is valid but missing required keys' do
      stub_request(:get, version_url).to_return(status: 200, body: '{}')

      result = host.send(:fetch_and_cache_versions)

      expect(result).to be_nil
      expect(host.warning_messages.join).to include('Invalid response')
      expect(host.warning_messages.join).to include(base_url)
    end
  end

  describe '#fetch_validator_version (private)' do
    it 'returns nil and warns on Faraday errors' do
      allow(Faraday).to receive(:get).and_raise(Faraday::ConnectionFailed.new('refused'))

      result = host.send(:fetch_validator_version, base_url)

      expect(result).to be_nil
      expect(host.warning_messages.join).to include('Error connecting to validator')
      expect(host.warning_messages.join).to include(base_url)
    end
  end

  describe '#parse_response (private)' do
    it 'warns and returns nil on invalid JSON' do
      result = host.send(:parse_response, 'not json')

      expect(result).to be_nil
      expect(host.warning_messages.join).to include('Error parsing response from validator')
    end
  end

  describe '#response_valid? (private)' do
    it 'returns false when a required key is missing' do
      data = { 'validatorVersion' => '1' }
      expect(host.send(:response_valid?, data)).to be false
    end

    it 'returns true when both keys are present' do
      data = { 'validatorVersion' => '1', 'validatorWrapperVersion' => '2' }
      expect(host.send(:response_valid?, data)).to be true
    end
  end

  describe '#read_or_create_validator_version (private)' do
    it 'returns cached values without another HTTP call when scratch is set' do
      host.scratch[:validator_version] = 'cached-v'
      host.scratch[:validator_wrapper_version] = 'cached-w'

      expect(host.send(:read_or_create_validator_version)).to eq(
        'validator_version' => 'cached-v',
        'validator_wrapper_version' => 'cached-w'
      )
    end
  end

  describe '#build_version_hash (private)' do
    it 'maps arguments to the expected string keys' do
      expect(host.send(:build_version_hash, 'v', 'w')).to eq(
        'validator_version' => 'v',
        'validator_wrapper_version' => 'w'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
