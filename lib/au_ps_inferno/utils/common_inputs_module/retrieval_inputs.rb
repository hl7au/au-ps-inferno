# frozen_string_literal: true

module AUPSTestKit
  # `input` declarations specific to the `url` and `fhir_server` retrieval methods, split
  # out of CommonInputsModule so each method/module stays within the length cops.
  module CommonInputsRetrievalInputs
    def retrieve_bundle_inputs(klass)
      retrieve_bundle_auth_detail_inputs(klass)
      retrieve_bundle_resource_inputs(klass)
    end

    def retrieve_bundle_auth_detail_inputs(klass)
      klass.input :header_name_retrieve, title: 'Header name', optional: true,
                                         enable_when: { input_name: 'retrieval_method', value: 'url' }
      klass.input :header_value_retrieve, title: 'Header value', optional: true,
                                          enable_when: { input_name: 'retrieval_method', value: 'url' }
    end

    def retrieve_bundle_resource_inputs(klass)
      klass.input :bundle_url,
                  title: 'Bundle URL',
                  optional: true,
                  description: 'To retrieve document Bundle using HTTP GET request',
                  enable_when: { input_name: 'retrieval_method', value: 'url' }
    end

    def fhir_server_inputs(klass)
      fhir_server_connection_inputs(klass)
      fhir_server_auth_detail_inputs(klass)
      fhir_server_resource_inputs(klass)
    end

    def fhir_server_connection_inputs(klass)
      klass.input :url_fhir_server, title: 'FHIR Server Base Url', optional: true,
                                    enable_when: { input_name: 'retrieval_method', value: 'fhir_server' }
      klass.input :auth_needed_fhir_server, title: 'Authentication needed?', type: 'radio', options: {
        list_options: [
          { value: 'true', label: 'Yes' },
          { value: 'false', label: 'No' }
        ]
      }, default: 'false', enable_when: { input_name: 'retrieval_method', value: 'fhir_server' }
    end

    def fhir_server_auth_detail_inputs(klass)
      klass.input :credentials_fhir_server, title: 'OAuth Credentials', type: :oauth_credentials, optional: true,
                                            enable_when: { input_name: 'auth_needed_fhir_server', value: 'true' }
      klass.input :header_name_fhir_server, title: 'Header name', optional: true,
                                            enable_when: { input_name: 'auth_needed_fhir_server', value: 'true' }
      klass.input :header_value_fhir_server, title: 'Header value', optional: true,
                                             enable_when: { input_name: 'auth_needed_fhir_server', value: 'true' }
    end

    def fhir_server_resource_inputs(klass)
      klass.input :patient_id,
                  title: 'Patient ID',
                  optional: true,
                  description: 'To request Patient/{patient_id}/$summary',
                  enable_when: { input_name: 'retrieval_method', value: 'fhir_server' }
      klass.input :identifier,
                  title: 'Patient Identifier',
                  optional: true,
                  description: 'To request Patient/$summary?identifier={identifier}',
                  enable_when: { input_name: 'retrieval_method', value: 'fhir_server' }
      klass.input :bundle_id,
                  title: 'Bundle ID',
                  optional: true,
                  description: 'To request Bundle/{bundle_id}',
                  enable_when: { input_name: 'retrieval_method', value: 'fhir_server' }
    end
  end
end
