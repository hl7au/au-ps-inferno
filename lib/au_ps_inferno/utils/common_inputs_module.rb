# frozen_string_literal: true

module AUPSTestKit
  # Shared `input` declarations reused across the top-level AU PS test groups
  # (au_ps_retrieve_cs_group, retrieve_bundle, generate_and_retrieve_bundle_via_summary),
  # so the same FHIR server, bundle and $summary inputs aren't redeclared in each one.
  module CommonInputsModule
    def self.shared_inputs(klass)
      klass.input_order :retrieval_method,
                        :url_sum, :auth_needed_sum, :credentials_sum, :header_name_sum, :header_value_sum,
                        :url_retrieve, :auth_needed_retrieve, :credentials_retrieve, :header_name_retrieve, :header_value_retrieve,
                        :bundle_id, :bundle_url, :patient_id, :identifier, :profile, :bundle_resource, :validate_against

      klass.input :retrieval_method, title: 'Bundle retrieval method', type: 'radio', options: {
        list_options: [
          { value: 'json_file', label: 'JSON file' },
          { value: 'url', label: 'URL to FHIR Bundle' },
          { value: 'summary_op', label: '$summary Operation' }
        ]
      }, default: 'json_file'

      klass.input :bundle_resource,
                  optional: true,
                  description: 'If you want to check existing Bundle resource',
                  type: 'textarea',
                  enable_when: { input_name: 'retrieval_method', value: 'json_file' }

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
      retrieve_bundle_inputs(klass)
      summary_operation_inputs(klass)
      configure_fhir_client(klass)
      define_url_helper(klass)
    end

    def self.define_url_helper(klass)
      url_method = proc do
        case retrieval_method
        when 'url' then url_retrieve
        when 'summary_op' then url_sum
        end
      end

      klass.send(:define_method, :url, &url_method)

      # `klass` may be a TestGroup declaring these inputs for tests added via
      # `test from: :some_id`. Those tests are separate classes, not subclasses
      # of `klass`, so the method above must be defined on each of them directly
      # for it to be reachable when the test actually runs.
      return unless klass.respond_to?(:tests)

      klass.tests.each { |test_klass| test_klass.send(:define_method, :url, &url_method) }
    end

    def self.configure_fhir_client(klass)
      klass.fhir_client do
        case retrieval_method
        when 'url'
          url :url_retrieve
          oauth_credentials :credentials_retrieve
          headers(CommonInputsModule.build_headers(header_name_retrieve, header_value_retrieve))
        when 'summary_op'
          url :url_sum
          oauth_credentials :credentials_sum
          headers(CommonInputsModule.build_headers(header_name_sum, header_value_sum))
        end
      end
    end

    def self.build_headers(name, value)
      name.present? && value.present? ? { name => value } : {}
    end

    def self.retrieve_bundle_inputs(klass)
      klass.input :url_retrieve, title: 'FHIR Server Base Url', optional: true,
                                 enable_when: { input_name: 'retrieval_method', value: 'url' }
      klass.input :auth_needed_retrieve, title: 'Authentication needed?', type: 'radio', options: {
        list_options: [
          { value: 'true', label: 'Yes' },
          { value: 'false', label: 'No' }
        ]
      }, default: 'false', enable_when: { input_name: 'retrieval_method', value: 'url' }
      klass.input :credentials_retrieve, title: 'OAuth Credentials', type: :oauth_credentials, optional: true,
                                         enable_when: { input_name: 'auth_needed_retrieve', value: 'true' }
      klass.input :header_name_retrieve, title: 'Header name', optional: true,
                                         enable_when: { input_name: 'auth_needed_retrieve', value: 'true' }
      klass.input :header_value_retrieve, title: 'Header value', optional: true,
                                          enable_when: { input_name: 'auth_needed_retrieve', value: 'true' }

      klass.input :bundle_id,
                  optional: true,
                  description: 'To request Bundle/{bundle_id}',
                  enable_when: { input_name: 'retrieval_method', value: 'url' }
      klass.input :bundle_url,
                  optional: true,
                  description: 'To retrieve document Bundle using HTTP GET request',
                  enable_when: { input_name: 'retrieval_method', value: 'url' }
    end

    def self.summary_operation_inputs(klass)
      klass.input :url_sum, title: 'FHIR Server Base Url', optional: true,
                            enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
      klass.input :auth_needed_sum, title: 'Authentication needed?', type: 'radio', options: {
        list_options: [
          { value: 'true', label: 'Yes' },
          { value: 'false', label: 'No' }
        ]
      }, default: 'false', enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
      klass.input :credentials_sum, title: 'OAuth Credentials', type: :oauth_credentials, optional: true,
                                    enable_when: { input_name: 'auth_needed_sum', value: 'true' }
      klass.input :header_name_sum, title: 'Header name', optional: true,
                                    enable_when: { input_name: 'auth_needed_sum', value: 'true' }
      klass.input :header_value_sum, title: 'Header value', optional: true,
                                     enable_when: { input_name: 'auth_needed_sum', value: 'true' }
      klass.input :patient_id,
                  optional: true,
                  description: 'To request Patient/{patient_id}/$summary',
                  enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
      klass.input :identifier,
                  optional: true,
                  description: 'To request Patient/$summary?identifier={identifier}',
                  enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
      klass.input :profile,
                  optional: true,
                  default: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle',
                  description: 'To specify profile for the patient summary',
                  enable_when: { input_name: 'retrieval_method', value: 'summary_op' }
    end
  end
end
