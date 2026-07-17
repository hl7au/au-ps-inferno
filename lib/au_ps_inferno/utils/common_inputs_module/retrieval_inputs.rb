# frozen_string_literal: true

module AUPSTestKit
  # `input` declarations specific to the `url` and `summary_op` retrieval methods, split
  # out of CommonInputsModule so each method/module stays within the length cops.
  module CommonInputsRetrievalInputs
    def retrieve_bundle_inputs(klass)
      retrieve_bundle_connection_inputs(klass)
      retrieve_bundle_auth_detail_inputs(klass)
      retrieve_bundle_resource_inputs(klass)
    end

    def retrieve_bundle_connection_inputs(klass)
      klass.input :url_retrieve, title: 'FHIR Server Base Url', optional: true,
                                 enable_when: { input_name: 'retrieval_method', value: 'url' }
      klass.input :auth_needed_retrieve, title: 'Authentication needed?', type: 'radio', options: {
        list_options: [
          { value: 'true', label: 'Yes' },
          { value: 'false', label: 'No' }
        ]
      }, default: 'false', enable_when: { input_name: 'retrieval_method', value: 'url' }
    end

    def retrieve_bundle_auth_detail_inputs(klass)
      klass.input :credentials_retrieve, title: 'OAuth Credentials', type: :oauth_credentials, optional: true,
                                         enable_when: { input_name: 'auth_needed_retrieve', value: 'true' }
      klass.input :header_name_retrieve, title: 'Header name', optional: true,
                                         enable_when: { input_name: 'auth_needed_retrieve', value: 'true' }
      klass.input :header_value_retrieve, title: 'Header value', optional: true,
                                          enable_when: { input_name: 'auth_needed_retrieve', value: 'true' }
    end

    def retrieve_bundle_resource_inputs(klass)
      klass.input :bundle_id,
                  optional: true,
                  description: 'To request Bundle/{bundle_id}',
                  enable_when: { input_name: 'retrieval_method', value: 'url' }
      klass.input :bundle_url,
                  optional: true,
                  description: 'To retrieve document Bundle using HTTP GET request',
                  enable_when: { input_name: 'retrieval_method', value: 'url' }
    end

    def summary_operation_inputs(klass)
      summary_connection_inputs(klass)
      summary_auth_detail_inputs(klass)
      summary_resource_inputs(klass)
      summary_profile_input(klass)
    end

    def summary_connection_inputs(klass)
      klass.input :url_sum, title: 'FHIR Server Base Url', optional: true,
                            enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
      klass.input :auth_needed_sum, title: 'Authentication needed?', type: 'radio', options: {
        list_options: [
          { value: 'true', label: 'Yes' },
          { value: 'false', label: 'No' }
        ]
      }, default: 'false', enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
    end

    def summary_auth_detail_inputs(klass)
      klass.input :credentials_sum, title: 'OAuth Credentials', type: :oauth_credentials, optional: true,
                                    enable_when: { input_name: 'auth_needed_sum', value: 'true' }
      klass.input :header_name_sum, title: 'Header name', optional: true,
                                    enable_when: { input_name: 'auth_needed_sum', value: 'true' }
      klass.input :header_value_sum, title: 'Header value', optional: true,
                                     enable_when: { input_name: 'auth_needed_sum', value: 'true' }
    end

    def summary_resource_inputs(klass)
      klass.input :patient_id,
                  optional: true,
                  description: 'To request Patient/{patient_id}/$summary',
                  enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
      klass.input :identifier,
                  optional: true,
                  description: 'To request Patient/$summary?identifier={identifier}',
                  enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
    end

    def summary_profile_input(klass)
      klass.input :profile,
                  optional: true,
                  default: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle',
                  description: 'To specify profile for the patient summary',
                  enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
    end
  end
end
