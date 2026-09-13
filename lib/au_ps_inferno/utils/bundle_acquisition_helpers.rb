# frozen_string_literal: true

module AUPSTestKit
  # Shared helpers for the five bundle-acquisition tests under suite_bundle_acquisition.
  module BundleAcquisitionHelpers
    AU_PS_BUNDLE_PROFILE = 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle'

    def parse_bundle(body)
      FHIR.from_contents(body)
    rescue StandardError
      nil
    end

    def extra_headers
      return {} if bundle_url_header_name.blank? || bundle_url_header_value.blank?

      { bundle_url_header_name => bundle_url_header_value }
    end

    def finish_acquisition(resource)
      save_bundle_to_scratch(resource)
      scratch[:validate_against] = validate_against
    end
  end
end
