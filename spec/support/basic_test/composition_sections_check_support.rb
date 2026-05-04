# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/utils/composition_utils'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

module CompositionSectionsCheckSupport
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

  def messages_for(result)
    Inferno::Repositories::Messages.new.messages_for_result(result.id)
  end

  def build_bundle(sections:, extra_entries: []) # rubocop:disable Metrics/MethodLength
    composition_entry = FHIR::Bundle::Entry.new(
      fullUrl: 'urn:uuid:composition-1',
      resource: FHIR::Composition.new(
        resourceType: 'Composition',
        status: 'final',
        type: { coding: [{ code: '60591-5' }] },
        subject: { reference: 'urn:uuid:patient-1' },
        section: sections
      )
    )
    patient_entry = FHIR::Bundle::Entry.new(
      fullUrl: 'urn:uuid:patient-1',
      resource: FHIR::Patient.new
    )
    FHIR::Bundle.new(
      resourceType: 'Bundle',
      type: 'document',
      entry: [composition_entry, patient_entry] + extra_entries
    )
  end

  def section_without_entries(code)
    { code: { coding: [{ code: code }] } }
  end

  def section_with_entry(code, reference)
    { code: { coding: [{ code: code }] }, entry: [{ reference: reference }] }
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
