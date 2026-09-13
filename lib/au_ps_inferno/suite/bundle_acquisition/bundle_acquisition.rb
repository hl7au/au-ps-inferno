# frozen_string_literal: true

require_relative 'suite_bundle_acquisition_from_resource'
require_relative 'suite_bundle_acquisition_from_url'
require_relative 'suite_bundle_acquisition_from_bundle_id'
require_relative 'suite_bundle_acquisition_from_patient_id'
require_relative 'suite_bundle_acquisition_from_identifier'

module AUPSTestKit
  # Loads the AU PS Bundle for every other group in the suite. Exactly one of the five tests
  # below runs, matching whichever acquisition method the user selects; the rest are omitted.
  class AUPSSuiteBundleAcquisition < Inferno::TestGroup
    title 'Provide AU PS Bundle'
    description 'Provide the Bundle to validate: paste a Bundle resource, give a Bundle URL, or ' \
                'give a FHIR server URL with a Bundle ID, Patient ID, or Patient identifier ' \
                '(IPS $summary). The result is stored for every other group in this suite.'
    id :suite_bundle_acquisition

    run_as_group

    test from: :suite_bundle_acquisition_from_resource

    test from: :suite_bundle_acquisition_from_url

    test from: :suite_bundle_acquisition_from_bundle_id

    test from: :suite_bundle_acquisition_from_patient_id

    test from: :suite_bundle_acquisition_from_identifier
  end
end
