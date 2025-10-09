# frozen_string_literal: true

require_relative './au_ps_capability_statement_test'


module AUPSTestKit
  class CapabilityStatementGroup < Inferno::TestGroup
    title 'CapabilityStatement tests'
    description "Verifies that the server provides a valid CapabilityStatement resource declaring support for required FHIR operations. This group checks that the server's CapabilityStatement includes the IPS $summary operation (for generating International Patient Summaries) and the $docref operation (for retrieving clinical documents), as specified in the IPS and IPA implementation guides."
    id :au_ps_cs_group
    run_as_group

    test from: :au_ps_capability_statement_exists_and_valid

  end
end
