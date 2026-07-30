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

RSpec.describe 'AU PS production suppression list' do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100') }
  let(:validator) { suite.find_validator(:default) }

  def message(type, text)
    Inferno::Entities::Message.new(type: type, message: text)
  end

  it 'excludes the Bundle.meta.profile empty-value false positive' do
    text = "Bundle/aups-basicsummary: Bundle: Bundle.meta.profile: The property's value cannot be empty"
    expect(validator.exclude_message.call(message('error', text))).to be true
  end

  it 'excludes an unknown PBS item code error' do
    text = "MedicationRequest/med-1: MedicationRequest: Unknown code '2951H' in the CodeSystem " \
           "'http://pbs.gov.au/code/item'"
    expect(validator.exclude_message.call(message('error', text))).to be true
  end

  it 'excludes a missing PBS CodeSystem definition warning' do
    text = 'MedicationRequest/med-1: MedicationRequest: A definition for CodeSystem ' \
           "'http://pbs.gov.au/code/item' could not be found, so the code cannot be validated"
    expect(validator.exclude_message.call(message('warning', text))).to be true
  end

  it 'excludes a missing MIMS CodeSystem definition warning' do
    text = 'MedicationRequest/med-1: MedicationRequest: A definition for CodeSystem ' \
           "'http://www.mims.com.au/codes' could not be found, so the code cannot be validated"
    expect(validator.exclude_message.call(message('warning', text))).to be true
  end

  it 'excludes a missing SNOMED CT CodeSystem definition warning' do
    text = "Condition/cond-1: Condition: A definition for CodeSystem 'http://snomed.info/sct' " \
           "version 'null' could not be found, so the code cannot be validated"
    expect(validator.exclude_message.call(message('warning', text))).to be true
  end

  it 'excludes an unresolvable value set check warning' do
    text = 'Condition/cond-1: Condition: Unable to check whether the code is in the value set ' \
           "'http://example.org/vs' because the code system http://snomed.info/sct was not found"
    expect(validator.exclude_message.call(message('warning', text))).to be true
  end

  it 'does not exclude an unrelated error' do
    text = 'Patient/pat-1: Patient: Patient.name: minimum required = 1, but only found 0'
    expect(validator.exclude_message.call(message('error', text))).to be false
  end
end
