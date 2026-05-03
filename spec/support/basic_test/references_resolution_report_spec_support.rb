# frozen_string_literal: true

RSpec.shared_context 'references resolution report setup' do # rubocop:disable Metrics/BlockLength
  let(:test_class) do
    Class.new(AUPSTestKit::BasicTest) do
      attr_accessor :metadata_manager
    end
  end
  let(:test_instance) { test_class.new }

  def build_bundle(section_code:, references:, bundle_entries:) # rubocop:disable Metrics/MethodLength
    composition_entry = FHIR::Bundle::Entry.new(
      fullUrl: 'urn:uuid:composition-1',
      resource: FHIR::Composition.new(
        resourceType: 'Composition',
        status: 'final',
        type: { coding: [{ code: '60591-5' }] },
        subject: { reference: 'urn:uuid:patient-1' },
        section: [
          {
            code: { coding: [{ code: section_code }] },
            entry: references.map { |ref| { reference: ref } }
          }
        ]
      )
    )
    patient_entry = FHIR::Bundle::Entry.new(
      fullUrl: 'urn:uuid:patient-1',
      resource: FHIR::Patient.new
    )
    author_entry = FHIR::Bundle::Entry.new(
      fullUrl: 'urn:uuid:author-1',
      resource: FHIR::Practitioner.new
    )
    bundle_entries = [composition_entry, patient_entry, author_entry, *bundle_entries]
    bundle_resource = FHIR::Bundle.new(
      resourceType: 'Bundle',
      type: 'document',
      entry: bundle_entries
    )

    BundleDecorator.new(bundle_resource)
  end
end
