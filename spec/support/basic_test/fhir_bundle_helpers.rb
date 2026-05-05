# frozen_string_literal: true

module FhirBundleHelpers
  def build_bundle(sections:, extra_entries: [])
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
end
