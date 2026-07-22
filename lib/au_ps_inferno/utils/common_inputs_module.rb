# frozen_string_literal: true

module AUPSTestKit
  # Shared `input` declarations for the FHIR server URL, OAuth credentials, and custom auth
  # header, reused identically across the top-level AU PS test groups (au_ps_retrieve_cs_group,
  # RetrieveBundleTestClass, GenerateSummaryBundleTestClass), so they aren't redeclared in each.
  module CommonInputsModule
    def self.validate_against_inputs(klass)
      klass.input :validate_against,
                  title: 'Validate Against',
                  optional: true,
                  type: 'checkbox',
                  default: %w[au_ps_bundle],
                  options: {
                    list_options: [
                      {
                        label: 'AU PS Bundle Validation',
                        value: 'au_ps_bundle'
                      },
                      {
                        label: 'IPS Bundle Validation',
                        value: 'ips_bundle'
                      }
                    ]
                  }
    end

    def self.retrieve_bundle_inputs(klass)
      klass.input :bundle_id,
                  optional: true,
                  description: 'To request Bundle/{bundle_id}'

      klass.input :bundle_url,
                  optional: true,
                  description: 'To retrieve document Bundle using HTTP GET request'
    end

    def self.bundle_resource_inputs(klass)
      klass.input :bundle_resource,
                  optional: true,
                  description: 'If you want to check existing Bundle resource',
                  type: 'textarea'
    end

    def self.summary_inputs(klass)
      klass.input :patient_id,
                  optional: true,
                  description: 'To request Patient/{patient_id}/$summary'

      klass.input :identifier,
                  optional: true,
                  description: 'To request Patient/$summary?identifier={identifier}'

      klass.input :profile,
                  optional: true,
                  default: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle',
                  description: 'To specify profile for the patient summary'
    end

    def self.shared_inputs(klass)
      server_connection_inputs(klass)
      auth_header_inputs(klass)
      configure_fhir_client(klass)
    end

    def self.server_connection_inputs(klass)
      klass.input :url,
                  title: 'FHIR Server Base Url',
                  optional: true

      klass.input :credentials,
                  title: 'OAuth Credentials',
                  type: :oauth_credentials,
                  optional: true
    end

    def self.auth_header_inputs(klass)
      klass.input :header_name,
                  title: 'Header name',
                  optional: true

      klass.input :header_value,
                  title: 'Header value',
                  optional: true
    end

    def self.configure_fhir_client(klass)
      klass.fhir_client do
        url :url
        oauth_credentials :credentials
        headers(header_name.present? && header_value.present? ? { header_name => header_value } : {})
      end
    end
  end
end
