# frozen_string_literal: true

module FhirBundleHelpers
  def condition_entry(url: 'urn:uuid:condition-1', meta_profile: nil)
    attrs = {
      resourceType: 'Condition',
      category: [{ coding: [{ code: 'problem-list-item' }] }],
      code: { coding: [{ code: '160245001' }] },
      subject: { reference: 'urn:uuid:patient-1' }
    }
    attrs[:meta] = { profile: [meta_profile] } if meta_profile
    FHIR::Bundle::Entry.new(fullUrl: url, resource: FHIR::Condition.new(attrs))
  end

  def observation_entry(url: 'urn:uuid:observation-1')
    FHIR::Bundle::Entry.new(
      fullUrl: url,
      resource: FHIR::Observation.new(resourceType: 'Observation', status: 'final',
                                      code: { coding: [{ code: '1234-5' }] })
    )
  end

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
