# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/utils/composition_utils'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

module CompositionSectionsCheckSupport
  def register_runnable_tree(runnable)
    repo_for(runnable)&.then { |repo| repo.insert(runnable) unless repo.exists?(runnable.id) }
    return unless runnable.respond_to?(:children)

    runnable.children.each { |child| register_runnable_tree(child) }
  end

  def repo_for(runnable)
    return Inferno::Repositories::TestSuites.new if runnable < Inferno::Entities::TestSuite
    return Inferno::Repositories::TestGroups.new if runnable < Inferno::Entities::TestGroup
    return Inferno::Repositories::Tests.new if runnable < Inferno::Entities::Test

    nil
  end

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
end

RSpec.shared_context 'composition sections check setup' do
  include CompositionSectionsCheckSupport

  let(:suite_id) { 'composition_sections_check_suite' }
  let(:suite) { described_class }

  before { register_runnable_tree(described_class) }
end
