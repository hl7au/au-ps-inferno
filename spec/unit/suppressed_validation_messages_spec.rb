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
