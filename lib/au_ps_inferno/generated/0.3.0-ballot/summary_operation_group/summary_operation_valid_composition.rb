# frozen_string_literal: true

module AUPSTestKit
  class SummaryOperationValidComposition < Inferno::Test
    title 'Server returns Bundle resource containing valid Composition entry'
    description 'Server return valid Composition resource in the Bundle as first entry'
    id :au_ps_summary_operation_valid_composition
    uses_request :summary_operation

    run do
      skip_if !resource.is_a?(FHIR::Bundle), 'No Bundle returned from document operation'
      assert resource.entry.length.positive?, 'Bundle has no entries'

      first_resource = resource.entry.first.resource

      assert first_resource.is_a?(FHIR::Composition), 'The first entry in the Bundle is not a Composition'
      assert_valid_resource(resource: first_resource, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition')
    end
  end
end
