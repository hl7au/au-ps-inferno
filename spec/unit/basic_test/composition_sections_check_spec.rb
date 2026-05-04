# frozen_string_literal: true

require 'yaml'
require 'json'
require 'fhir_models'

require_relative '../../fixtures/composition_check_suite'
require_relative '../../support/basic_test/composition_sections_check_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.describe CompositionSectionsCheckSuiteKit::CompositionSectionsCheckSuite do
  include_context 'when testing a runnable'
  include CompositionSectionsCheckSupport

  let(:suite_id) { 'composition_sections_check_suite' }
  let(:suite) { described_class }
  let(:test) { find_test(suite, 'sections_shall_populated') }

  before do
    register_runnable_tree(described_class)
    configure_test_class(test)
  end

  describe 'sections_shall_populated test' do
    it 'passes for a valid mandatory bundle fixture' do
      result = run(test, {}, scratch_with_bundle_fixture)
      messages = Inferno::Repositories::Messages.new.messages_for_result(result.id)

      puts messages.inspect

      expect(messages).not_to be_empty
      expect(result.result).to eq('pass'), result.result_message
    end
  end
end
