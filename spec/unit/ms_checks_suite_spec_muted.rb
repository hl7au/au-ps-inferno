# frozen_string_literal: true

require 'yaml'
require 'json'
require 'fhir_models'

require_relative '../fixtures/ms_checks_suite'
require_relative '../support/ms_checks_suite_spec_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.describe MSCheckSuiteKit::MSCheckSuite do
  include_context 'when testing a runnable'
  include MsChecksSuiteSpecSupport

  let(:suite_id) { 'ms_check_suite' }
  let(:suite) { described_class }
  let(:test) { find_test(suite, 'mandatory_ms_elements_populated') }

  before do
    register_runnable_tree(described_class)
    configure_test_class(test)
  end

  describe 'mandatory_ms_elements_populated test' do
    it 'passes for a valid mandatory bundle fixture' do
      result = run(test, {}, scratch_with_bundle_fixture)
      messages = Inferno::Repositories::Messages.new.messages_for_result(result.id)

      puts messages.inspect

      expect(messages).not_to be_empty
      expect(result.result).to eq('pass'), result.result_message
    end
  end
end
