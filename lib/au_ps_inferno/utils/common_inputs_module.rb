# frozen_string_literal: true

module AUPSTestKit
  # Shared `input` declarations for the bundle-acquisition test classes used by the
  # single-file suite (ProvidedBundleTestClass, RetrieveBundleTestClass,
  # GenerateSummaryBundleTestClass) and the CapabilityStatement group
  # (AUPSRetrieveCSGroup100preview).
  #
  # All of them declare the same `bundle_retrieve_method` radio input, and gate their
  # own fields on it via `enable_when`, so a suite-wide run shows one "how do you want
  # to provide the Bundle?" choice instead of every acquisition method's fields at once
  # (issue #86). `header_name`/`header_value`/`url`/`credentials` are intentionally
  # reused with an identical `fhir_server` condition across the FHIR Server and
  # CapabilityStatement inputs so the merged suite-wide input keeps a single
  # enable_when condition; the Bundle URL path gets its own
  # `bundle_url_header_name`/`bundle_url_header_value` pair so its condition can't be
  # clobbered by that merge.
  module CommonInputsModule # rubocop:disable Metrics/ModuleLength
    SINGLE_INPUT_DEFINITIONS = {
      bundle_retrieve_method_input: [:bundle_retrieve_method, {
        title: 'Bundle Retrieval Method',
        optional: true,
        type: 'radio',
        options: {
          list_options: [
            { label: 'Bundle Resource', value: 'bundle_resource' },
            { label: 'FHIR Server', value: 'fhir_server' },
            { label: 'Bundle URL', value: 'bundle_url' }
          ]
        }
      }],
      bundle_resource_input: [:bundle_resource, {
        title: 'Bundle Resource', optional: true, type: 'textarea',
        description: 'If you want to check existing Bundle resource',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'bundle_resource' }
      }],
      bundle_url_input: [:bundle_url, {
        title: 'Bundle URL', optional: true, description: 'To retrieve document Bundle using HTTP GET request',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'bundle_url' }
      }],
      bundle_url_header_name_input: [:bundle_url_header_name, {
        title: 'Header name', optional: true,
        enable_when: { input_name: 'bundle_retrieve_method', value: 'bundle_url' }
      }],
      bundle_url_header_value_input: [:bundle_url_header_value, {
        title: 'Header value', optional: true,
        enable_when: { input_name: 'bundle_retrieve_method', value: 'bundle_url' }
      }],
      fhir_server_url_input: [:url, {
        title: 'FHIR Server Base Url', optional: true,
        enable_when: { input_name: 'bundle_retrieve_method', value: 'fhir_server' }
      }],
      bundle_id_input: [:bundle_id, {
        title: 'Bundle ID', optional: true, description: 'To request Bundle/{bundle_id}',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'fhir_server' }
      }],
      patient_id_input: [:patient_id, {
        title: 'Patient ID', optional: true, description: 'To request Patient/{patient_id}/$summary',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'fhir_server' }
      }],
      patient_identifier_input: [:identifier, {
        title: 'Patient Identifier', optional: true,
        description: 'To request Patient/$summary?identifier={identifier}',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'fhir_server' }
      }],
      profile_input: [:profile, {
        title: 'Profile URL', optional: true,
        default: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle',
        description: 'To specify profile for the patient summary',
        enable_when: { input_name: 'bundle_retrieve_method', value: 'fhir_server' }
      }],
      credentials_input: [:credentials, {
        title: 'OAuth Credentials', type: :oauth_credentials, optional: true,
        enable_when: { input_name: 'bundle_retrieve_method', value: 'fhir_server' }
      }],
      header_name_input: [:header_name, {
        title: 'Header name', optional: true,
        enable_when: { input_name: 'bundle_retrieve_method', value: 'fhir_server' }
      }],
      header_value_input: [:header_value, {
        title: 'Header value', optional: true,
        enable_when: { input_name: 'bundle_retrieve_method', value: 'fhir_server' }
      }]
    }.freeze

    BUNDLE_RESOURCE_INPUTS_DEFINITION = %i[bundle_retrieve_method_input bundle_resource_input].freeze
    BUNDLE_URL_INPUTS_DEFINITION = %i[bundle_retrieve_method_input bundle_url_input
                                      bundle_url_header_name_input bundle_url_header_value_input].freeze
    FHIR_SERVER_INPUTS_DEFINITION = %i[bundle_retrieve_method_input fhir_server_url_input bundle_id_input
                                       patient_id_input patient_identifier_input profile_input
                                       credentials_input header_name_input header_value_input].freeze
    RETRIEVE_CS_INPUTS_DEFINITION = %i[bundle_retrieve_method_input fhir_server_url_input credentials_input
                                       header_name_input header_value_input].freeze

    SINGLE_INPUT_DEFINITIONS.each do |method_name, (input_name, options)|
      define_singleton_method(method_name) do |klass|
        klass.input input_name, **options
      end
    end

    INPUT_NAMES_BY_METHOD = SINGLE_INPUT_DEFINITIONS.transform_values { |(input_name, _)| [input_name] }.freeze

    def self.declare_inputs(klass, *method_names)
      klass.input_order(*method_names.flat_map { |method_name| INPUT_NAMES_BY_METHOD.fetch(method_name) })
      method_names.each { |method_name| public_send(method_name, klass) }
    end

    def self.bundle_resource_inputs(klass)
      declare_inputs(klass, *BUNDLE_RESOURCE_INPUTS_DEFINITION)
    end

    def self.bundle_url_inputs(klass)
      declare_inputs(klass, *BUNDLE_URL_INPUTS_DEFINITION)
    end

    def self.fhir_server_inputs(klass)
      declare_inputs(klass, *FHIR_SERVER_INPUTS_DEFINITION)
      configure_fhir_client(klass)
    end

    def self.retrieve_cs_inputs(klass)
      declare_inputs(klass, *RETRIEVE_CS_INPUTS_DEFINITION)
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
