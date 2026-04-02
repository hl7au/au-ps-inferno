# frozen_string_literal: true

module AUPSTestKit
  module BasicTestConstants
    # AU PS Patient Must Support sub-elements: validate when parent (name, telecom, communication) is populated.
    # communication.language is mandatory when communication is present; all others optional.
    PATIENT_MS_SUBELEMENT_GROUPS = [
      { parent: 'name', mandatory: [], optional: %w[name.use name.text name.family name.given] },
      { parent: 'telecom', mandatory: [], optional: %w[telecom.system telecom.value telecom.use] },
      { parent: 'communication', mandatory: ['communication.language'], optional: ['communication.preferred'] }
    ].freeze

    # AU PS Patient Must Support identifier slices (optional). System URLs for IHI, DVA, Medicare.
    PATIENT_MS_IDENTIFIER_SLICES = [
      { name: 'IHI', system: 'http://ns.electronichealth.net.au/id/hi/ihi/1.0' },
      { name: 'DVA', system: 'http://ns.electronichealth.net.au/id/dva' },
      { name: 'MEDICARE', system: 'http://ns.electronichealth.net.au/id/medicare-number' }
    ].freeze
    ORGANIZATION_MS_IDENTIFIER_SLICES = [
      { name: 'ABN', system: 'http://hl7.org.au/id/abn' },
      { name: 'HPIO', system: 'http://ns.electronichealth.net.au/id/hi/hpio/1.0' }
    ].freeze
    PRACTITIONER_ROLE_MS_IDENTIFIER_SLICES = [
      { name: 'MEDICARE PROVIDER', system: 'http://ns.electronichealth.net.au/id/medicare-provider-number' }
    ].freeze
    PRACTITIONER_MS_IDENTIFIER_SLICES = [
      { name: 'HPII', system: 'http://ns.electronichealth.net.au/id/hi/hpii/1.0' }
    ].freeze

    # Author resource type -> Must Support identifier slices (empty for Device, RelatedPerson).
    AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE = {
      'Practitioner' => PRACTITIONER_MS_IDENTIFIER_SLICES,
      'PractitionerRole' => PRACTITIONER_ROLE_MS_IDENTIFIER_SLICES,
      'Patient' => PATIENT_MS_IDENTIFIER_SLICES,
      'Organization' => ORGANIZATION_MS_IDENTIFIER_SLICES,
      'RelatedPerson' => [],
      'Device' => []
    }.freeze
  end
end
