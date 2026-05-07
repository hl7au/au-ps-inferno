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

  def build_bundle(sections:, extra_entries: [])
    FHIR::Bundle.new(
      resourceType: 'Bundle',
      type: 'document',
      entry: [build_composition_entry(sections), build_patient_entry] + extra_entries
    )
  end

  private

  def build_composition_entry(sections)
    FHIR::Bundle::Entry.new(
      fullUrl: 'urn:uuid:composition-1',
      resource: FHIR::Composition.new(
        resourceType: 'Composition',
        status: 'final',
        type: { coding: [{ code: '60591-5' }] },
        subject: { reference: 'urn:uuid:patient-1' },
        section: sections
      )
    )
  end

  def build_patient_entry
    FHIR::Bundle::Entry.new(
      fullUrl: 'urn:uuid:patient-1',
      resource: FHIR::Patient.new
    )
  end
end
