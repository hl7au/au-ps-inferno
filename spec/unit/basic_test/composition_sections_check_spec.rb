# frozen_string_literal: true

require 'yaml'
require 'json'
require 'fhir_models'

require_relative '../../fixtures/composition_check_suite'
require_relative '../../support/basic_test/composition_sections_check_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.describe CompositionSectionsCheckSuiteKit::CompositionSectionsCheckSuite do # rubocop:disable Metrics/BlockLength
  include_context 'when testing a runnable'
  include CompositionSectionsCheckSupport

  let(:suite_id) { 'composition_sections_check_suite' }
  let(:suite) { described_class }

  before { register_runnable_tree(described_class) }

  describe 'sections_shall_populated test' do # rubocop:disable Metrics/BlockLength
    let(:test) { find_test(suite, 'sections_shall_populated') }

    before { configure_test_class(test) }

    it 'passes when all mandatory sections are present' do
      bundle = build_bundle(sections: [
                              section_without_entries('11450-4'),
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('pass'), result.result_message
      expect(messages.none? { |m| m.type == 'error' }).to be(true)
      expect(messages.count { |m| m.type == 'info' }).to eq(3)
    end

    it 'fails when a mandatory section is absent from the composition' do
      bundle = build_bundle(sections: [
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      error_texts = messages.select { |m| m.type == 'error' }.map(&:message)
      expect(error_texts).to include(match(/No composition section found for code: 11450-4/))
    end

    it 'fails when a section entry reference does not resolve' do
      bundle = build_bundle(sections: [
                              section_with_entry('11450-4', 'urn:uuid:missing-condition-1'),
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      error_texts = messages.select { |m| m.type == 'error' }.map(&:message)
      expect(error_texts).to include(match(/❌ Reference does not resolve/))
    end

    it 'fails when a section entry references a resource of the wrong type' do
      observation_entry = FHIR::Bundle::Entry.new(
        fullUrl: 'urn:uuid:observation-1',
        resource: FHIR::Observation.new(resourceType: 'Observation', status: 'final',
                                        code: { coding: [{ code: '1234-5' }] })
      )
      bundle = build_bundle(
        sections: [
          section_with_entry('11450-4', 'urn:uuid:observation-1'),
          section_without_entries('48765-2'),
          section_without_entries('10160-0')
        ],
        extra_entries: [observation_entry]
      )
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      error_texts = messages.select { |m| m.type == 'error' }.map(&:message)
      expect(error_texts).to include(match(/❌ Invalid resource type/))
    end

    it 'skips when no bundle is provided in scratch' do
      result = run_test({})

      expect(result.result).to eq('skip')
    end
  end

  describe 'sections_should_populated test' do
    let(:test) { find_test(suite, 'sections_should_populated') }

    before { configure_test_class(test) }

    it 'passes when recommended sections are present' do
      bundle = build_bundle(sections: [
                              section_without_entries('11369-6'),
                              section_without_entries('30954-2')
                            ])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('pass'), result.result_message
      expect(messages.none? { |m| m.type == 'error' }).to be(true)
      expect(messages.count { |m| m.type == 'info' }).to eq(2)
    end

    it 'fails when a recommended section is absent from the composition' do
      bundle = build_bundle(sections: [section_without_entries('30954-2')])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      error_texts = messages.select { |m| m.type == 'error' }.map(&:message)
      expect(error_texts).to include(match(/No composition section found for code: 11369-6/))
    end
  end

  describe 'sections_may_populated test' do
    let(:test) { find_test(suite, 'sections_may_populated') }

    before { configure_test_class(test) }

    it 'passes when the optional section is present' do
      bundle = build_bundle(sections: [section_without_entries('42348-3')])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('pass'), result.result_message
      expect(messages.none? { |m| m.type == 'error' }).to be(true)
      expect(messages.count { |m| m.type == 'info' }).to eq(1)
    end

    it 'fails when the optional section is absent from the composition' do
      bundle = build_bundle(sections: [])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      error_texts = messages.select { |m| m.type == 'error' }.map(&:message)
      expect(error_texts).to include(match(/No composition section found for code: 42348-3/))
    end
  end
end
