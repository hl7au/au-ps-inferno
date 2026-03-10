# frozen_string_literal: true

class Generator
  # Constants used by the test generator for AU PS (Australian Patient Summary) Inferno.
  module Constants
    # Required AU PS FHIR profile URLs. Resources using these profiles must be present
    # for a valid patient summary.
    # @return [Array<String>]
    REQUIRED_PROFILES = %w[
      http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle
      http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-composition
      http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient
      http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition
      http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance
      http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement
      http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest
    ].freeze

    # Mapping from resource/profile (resourceType|profileUrl) to
    # an array of filters which restrict entries
    # for that resource type in section validation.
    #
    # Each filter is a hash specifying a FHIRPath 'path' and required 'value'.
    # The value can be a single value or an array of possible values.
    #
    # @return [Hash{String => Array<Hash{String => Object}>}]
    RESOURCES_FILTERS_MAPPING = {
      'Observation|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path' => [
        { 'path' => 'category.coding.code', 'value' => 'laboratory' }
      ],
      'Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-results-radiology-uv-ips' => [
        { 'path' => 'category.coding.code', 'value' => 'imaging' }
      ],
      'Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips' => [
        { 'path' => 'code.coding.code', 'value' => '82810-3' }
      ],
      'Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-outcome-uv-ips' => [
        {
          'path' => 'code.coding.code',
          'value' => %w[
            11636-8
            11637-6
            11638-4
            11639-2
            11640-0
            11612-9
            11613-7
            11614-5
            33065-4
          ]
        }
      ],
      'Observation|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-smokingstatus' => [
        { 'path' => 'code.coding.code', 'value' => '1747861000168109' }
      ],
      'Observation|http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-alcoholuse-uv-ips' => [
        { 'path' => 'code.coding.code', 'value' => '74013-4' }
      ]
    }.freeze
  end
end
