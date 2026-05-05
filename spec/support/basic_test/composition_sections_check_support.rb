# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/utils/composition_utils'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'
require_relative 'composition_sections_constants'
require_relative 'composition_sections_metadata'
require_relative 'fhir_bundle_helpers'

module CompositionSectionsCheckSupport
  include CompositionSectionsConstants
  include CompositionSectionsMetadata
  include FhirBundleHelpers

  def configure_test_class(test_class, metadata)
    manager = AUPSTestKit::MetadataManager.new(nil).tap do |m|
      allow(m).to receive(:metadata).and_return(metadata)
    end
    test_class.class_eval do
      include CompositionUtils unless ancestors.include?(CompositionUtils)
      unless ancestors.include?(AUPSTestKit::BasicTestCompositionSectionReadModule)
        include AUPSTestKit::BasicTestCompositionSectionReadModule
      end
      define_method(:metadata_manager) { manager }
    end
  end

  def run_test(scratch)
    run(test, {}, scratch)
  end

  def scratch_with(bundle)
    { bundle_ips_resource: bundle }
  end

  def run_with_sections(test, sections:, extra_entries: [])
    bundle = build_bundle(sections: sections, extra_entries: extra_entries)
    result = run(test, {}, scratch_with(bundle))
    { result: result, messages: messages_for(result) }
  end

  def expect_info_message(outcome, expected_message)
    expect(outcome[:messages]).to include_message(type: 'info', text: expected_message)
  end

  def expect_warning_message(outcome, expected_message)
    expect(outcome[:messages]).to include_message(type: 'warning', text: expected_message)
  end

  def expect_error_message(outcome, expected_message)
    expect(outcome[:messages]).to include_message(type: 'error', text: expected_message)
  end

  def outcome_expect_to_status(outcome, status)
    expect(outcome[:result].result).to(eq(status))
  end

  def expect_pass(outcome)
    outcome_expect_to_status(outcome, 'pass')
  end

  def expect_fail(outcome)
    outcome_expect_to_status(outcome, 'fail')
  end

  def expect_skip(outcome)
    outcome_expect_to_status(outcome, 'skip')
  end

  def expect_result_and_messages(result:, messages:, status:, expected_messages:)
    expect(result.result).to eq(status), result.result_message
    expect_messages(messages, expected_messages)
  end

  def messages_for(result)
    Inferno::Repositories::Messages.new.messages_for_result(result.id)
  end

  def expect_messages(messages, expected_messages)
    expect(messages.size).to eq(expected_messages.size)
    expected_messages.each do |expected_message|
      expect(messages).to include_message(type: expected_message[:type], text: expected_message[:text])
    end
  end

  def section_without_entries(code)
    { code: { coding: [{ code: code }] } }
  end

  def section_with_entries(code, *references)
    { code: { coding: [{ code: code }] }, entry: references.map { |ref| { reference: ref } } }
  end

  def section_with_entry(code, reference)
    section_with_entries(code, reference)
  end

  def section_with_empty_reason(code, display:, reason_code:)
    { code: { coding: [{ code: code }] }, emptyReason: { coding: [{ display: display, code: reason_code }] } }
  end
end

RSpec.shared_context 'composition sections check setup' do
  include CompositionSectionsCheckSupport

  let(:suite_id) { 'composition_sections_check_suite' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'composition_sections_check_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?(suite_id)
  end

  def find_test(method_name)
    test_id = "#{suite_id}-#{method_name}"
    test_class = Class.new(Inferno::Test) do
      id test_id
      run { send(method_name) }
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(test_class) unless repo.exists?(test_id)
    test_class
  end
end
