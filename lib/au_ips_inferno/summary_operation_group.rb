# frozen_string_literal: true

module AUIPSInferno
  # This test group verifies support for the `$summary` operation according to the IG
  class SummaryOperation < Inferno::TestGroup
    title 'Summary Operation Tests'
    description %(
        Verify support for the $summary operation as as described in the [IPS
        Guidance](http://hl7.org/fhir/uv/ips/STU1.1/ipsGeneration.html).
    )
    id :ips_summary_group
    run_as_group

    test from: :ips_summary_operation_support,
         config: {
           options: {
             ips_summary_operation_definition_url: 'http://hl7.org/fhir/uv/ips/OperationDefinition/summary'
           }
         }

    test from: :ips_summary_operation_return_bundle,
         config: {
           options: {
             ips_bundle_profile_url: 'http://hl7.org.au/fhir/ips/StructureDefinition/Bundle-au-ips'
           }
         }

    test from: :ips_summary_operation_valid_composition,
         config: {
           options: {
             ips_composition_profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Composition-au-ips'
           }
         }
  end
end
