# frozen_string_literal: true

require 'fhir_models'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'

RSpec.describe 'AU PS validation message suppression' do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100') }
  let(:validator) { suite.find_validator(:default) }

  def message(type, text)
    Inferno::Entities::Message.new(type: type, message: text)
  end

  around do |example|
    original = AUPSTestKit::AUPSSuitePreview::SUPPRESSED_VALIDATION_MESSAGES
    AUPSTestKit::AUPSSuitePreview.send(:remove_const, :SUPPRESSED_VALIDATION_MESSAGES)
    AUPSTestKit::AUPSSuitePreview.const_set(:SUPPRESSED_VALIDATION_MESSAGES, suppressions)
    example.run
  ensure
    AUPSTestKit::AUPSSuitePreview.send(:remove_const, :SUPPRESSED_VALIDATION_MESSAGES)
    AUPSTestKit::AUPSSuitePreview.const_set(:SUPPRESSED_VALIDATION_MESSAGES, original)
  end

  let(:suppressions) do
    [
      { type: 'warning', pattern: /known PBS terminology gap/, reason: 'test suppression' }
    ].freeze
  end

  it 'excludes a message matching both type and pattern' do
    expect(validator.exclude_message.call(message('warning', 'Bundle: known PBS terminology gap here'))).to be true
  end

  it 'does not exclude a message with matching text but a different type' do
    expect(validator.exclude_message.call(message('error', 'Bundle: known PBS terminology gap here'))).to be false
  end

  it 'does not exclude a message with matching type but non-matching text' do
    expect(validator.exclude_message.call(message('warning', 'Bundle: unrelated message'))).to be false
  end

  context 'with no suppressions configured' do
    let(:suppressions) { [].freeze }

    it 'excludes nothing' do
      expect(validator.exclude_message.call(message('error', 'anything'))).to be false
    end
  end
end

RSpec.describe AUPSTestKit::SuppressedValidationMessages do
  let(:validator) { Inferno::Repositories::TestSuites.new.find('au_ps_v100').find_validator(:default) }

  def fixture_messages(name)
    path = File.expand_path("../fixtures/validation_messages/#{name}.json", __dir__)
    JSON.parse(File.read(path))['messages'].map do |message|
      Inferno::Entities::Message.new(type: message['type'], message: message['message'])
    end
  end

  def visible(messages, type)
    messages.select { |message| message.type == type }.reject { |message| validator.exclude_message.call(message) }
  end

  describe 'LIST' do
    it 'gives every entry a valid type, a Regexp pattern and a reason' do
      described_class::LIST.each do |entry|
        expect(%w[error warning info]).to include(entry[:type])
        expect(entry[:pattern]).to be_a(Regexp)
        expect(entry[:reason]).to be_a(String).and(satisfy { |reason| !reason.strip.empty? })
      end
    end

    it 'has no entries bound to example UUIDs or ci-build versions' do
      described_class::LIST.each do |entry|
        expect(entry[:pattern].source).not_to match(/urn:uuid|ci-build/)
      end
    end
  end

  context 'with the IG referral-endoconsult-autogen example' do
    let(:messages) { fixture_messages('referral-endoconsult-autogen') }

    it 'suppresses the Bundle.signature.targetFormat MimeType false positives' do
      target_format_errors = messages.select do |message|
        message.type == 'error' && message.message.include?('Bundle.signature.targetFormat')
      end

      expect(target_format_errors.size).to eq(2)
      expect(target_format_errors).to all(satisfy { |message| validator.exclude_message.call(message) })
    end

    it 'leaves only the legitimate errors visible' do
      expect(visible(messages, 'error').map(&:message)).to contain_exactly(
        a_string_including('Device/null*/.identifier[0].system: Example URLs are not allowed'),
        a_string_including('Bundle.signature.who.identifier.system: Example URLs are not allowed'),
        a_string_including('At least one mandatory Must Support element is not populated')
      )
    end
  end

  context 'with a non-conformant Observation in the Bundle' do
    let(:messages) { fixture_messages('referral-endoconsult-autogen-broken-observation') }

    it 'does not suppress the Bundle slice conformance error' do
      expect(visible(messages, 'error').map(&:message)).to include(
        a_string_including('The entry resource did not match any of the allowed profiles (Type Observation:')
      )
    end
  end
end
