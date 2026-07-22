# frozen_string_literal: true

module AUPSTestKit
  # Shared `input` declarations for the FHIR server URL, OAuth credentials, and custom auth
  # header, reused identically across the top-level AU PS test groups (au_ps_retrieve_cs_group,
  # RetrieveBundleTestClass, GenerateSummaryBundleTestClass), so they aren't redeclared in each.
  module CommonInputsModule
    SINGLE_INPUT_DEFINITIONS = {
      bundle_retrieve_method_input: [:bundle_retrieve_method, {
        title: 'Retrieve Bundle method',
        optional: true,
        type: 'radio',
        options: {
          list_options: [
            {
              label: 'JSON input',
              value: 'json_input'
            },
            {
              label: 'Retrieve Bundle',
              value: 'retrieve_bundle'
            },
            {
              label: '$summary',
              value: 'summary_operation'
            }
          ]
        }
      }],
      validate_against_input: [:validate_against, {
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
      }],
      bundle_id_input: [:bundle_id, {
        title: 'Bundle ID', optional: true, description: 'To request Bundle/{bundle_id}',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'retrieve_bundle' }
      }],
      bundle_url_input: [:bundle_url, {
        title: 'Bundle URL', optional: true, description: 'To retrieve document Bundle using HTTP GET request',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'retrieve_bundle' }
      }],
      bundle_resource_input: [:bundle_resource, {
        title: 'Bundle Resource', optional: true,
        description: 'If you want to check existing Bundle resource', type: 'textarea',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'json_input' }
      }],
      patient_id_input: [:patient_id, {
        title: 'Patient ID', optional: true, description: 'To request Patient/{patient_id}/$summary',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'summary_operation' }
      }],
      patient_identifier_input: [:identifier, {
        title: 'Patient Identifier', optional: true, description: 'To request Patient/$summary?identifier={identifier}',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'summary_operation' }
      }],
      profile_input: [:profile, {
        title: 'Profile URL',
        optional: true,
        default: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle',
        description: 'To specify profile for the patient summary',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'summary_operation' }
      }],
      credentials_input: [:credentials, {
        title: 'OAuth Credentials', type: :oauth_credentials, optional: true
      }],
      fhir_server_url_input: [:url, {
        title: 'FHIR Server Base Url', optional: true
      }],
      header_name_input: [:header_name, {
        title: 'Header name', optional: true
      }],
      header_value_input: [:header_value, {
        title: 'Header value', optional: true
      }]
    }.freeze

    SINGLE_INPUT_DEFINITIONS.each do |method_name, (input_name, options)|
      define_singleton_method(method_name) do |klass|
        klass.input input_name, **options
      end
    end

    def self.authentication_inputs(klass)
      credentials_input(klass)
      header_name_input(klass)
      header_value_input(klass)
    end

    INPUT_NAMES_BY_METHOD = SINGLE_INPUT_DEFINITIONS.transform_values { |(input_name, _)| [input_name] }.merge(
      validate_against_input: [:validate_against],
      authentication_inputs: %i[credentials header_name header_value]
    ).freeze

    def self.declare_inputs(klass, *method_names)
      klass.input_order(*method_names.flat_map { |method_name| INPUT_NAMES_BY_METHOD.fetch(method_name) })
      method_names.each { |method_name| public_send(method_name, klass) }
    end

    def self.bundle_resource_inputs(klass)
      declare_inputs(klass, :validate_against_input, :bundle_retrieve_method_input, :bundle_resource_input)
    end

    def self.retrieve_bundle_inputs(klass)
      declare_inputs(klass, :validate_against_input, :bundle_url_input, :fhir_server_url_input, :bundle_id_input,
                     :authentication_inputs)

      configure_fhir_client(klass)
    end

    def self.summary_inputs(klass)
      declare_inputs(klass, :fhir_server_url_input, :patient_id_input, :patient_identifier_input,
                     :profile_input, :authentication_inputs, :validate_against_input)

      configure_fhir_client(klass)
    end

    def self.retrieve_cs_inputs(klass)
      declare_inputs(klass, :fhir_server_url_input, :authentication_inputs)

      configure_fhir_client(klass)
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
