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
  end
end
