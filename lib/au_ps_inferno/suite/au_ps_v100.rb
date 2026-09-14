# frozen_string_literal: true

require_relative '../version'

require_relative 'all_tests'

module AUPSTestKit
  # Test suite for the AU PS (Australian Primary Care and Shared Health) Implementation Guide.
  class AUPSSuitePreview < Inferno::TestSuite
    id :au_ps_v100
    title "AU PS #{AUPSTestKit::IG_VERSION} Test Suite"
    description 'Validates AU PS (Australian Primary Care and Shared Health) bundles, ' \
                'compositions, sections, and server CapabilityStatement support for the ' \
                "#{AUPSTestKit::IG_VERSION} implementation guide."

    fhir_resource_validator do
      igs "hl7.fhir.au.ps##{AUPSTestKit::IG_VERSION}"

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
        # The validator defaults snomedCT to the International edition
        # (900000000000207008) and turns it into an expansion parameter
        # "system-version=http://snomed.info/sct|http://snomed.info/sct/<edition>".
        # The AU terminology server carries only the Australian edition, so the
        # default makes every SNOMED lookup fail with "A definition for CodeSystem
        # 'http://snomed.info/sct' version 'null' could not be found", and the
        # validator then reports valid codes as absent from their value sets.
        # The AU edition is a derivative containing the full International release
        # plus the AU extension and AMT, so nothing is lost by selecting it, and
        # AMT codes (required binding on AU Core Medication.code.coding:amt) are
        # only resolvable here.
        snomedCT ENV.fetch('SNOMED_EDITION', 'au')
        noEcosystem true
      end
    end

    group from: :suite_all_tests
  end
end
