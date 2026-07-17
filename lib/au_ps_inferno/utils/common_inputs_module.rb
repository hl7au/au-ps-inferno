# frozen_string_literal: true

require_relative 'common_inputs_module/retrieval_inputs'

module AUPSTestKit
  # Shared `input` declarations reused across the top-level AU PS test groups
  # (au_ps_retrieve_cs_group, retrieve_bundle, generate_and_retrieve_bundle_via_summary),
  # so the same FHIR server, bundle and $summary inputs aren't redeclared in each one.
  module CommonInputsModule
    extend CommonInputsRetrievalInputs

    def self.shared_inputs(klass)
      order_inputs(klass)
      retrieval_method_input(klass)
      bundle_resource_input(klass)
      validate_against_input(klass)
      retrieve_bundle_inputs(klass)
      summary_operation_inputs(klass)
      configure_fhir_client(klass)
      define_url_helper(klass)
    end

    def self.order_inputs(klass)
      klass.input_order :retrieval_method,
                        :url_sum, :auth_needed_sum, :credentials_sum, :header_name_sum, :header_value_sum,
                        :url_retrieve, :auth_needed_retrieve, :credentials_retrieve, :header_name_retrieve,
                        :header_value_retrieve,
                        :bundle_id, :bundle_url, :patient_id, :identifier, :profile, :bundle_resource,
                        :validate_against
    end

    def self.retrieval_method_input(klass)
      klass.input :retrieval_method, title: 'Bundle retrieval method', type: 'radio', options: {
        list_options: [
          { value: 'json_file', label: 'JSON file' },
          { value: 'url', label: 'URL to FHIR Bundle' },
          { value: 'summary_op', label: '$summary Operation' }
        ]
      }, default: 'json_file'
    end

    def self.bundle_resource_input(klass)
      klass.input :bundle_resource,
                  optional: true,
                  description: 'If you want to check existing Bundle resource',
                  type: 'textarea',
                  enable_when: { input_name: 'retrieval_method', value: 'json_file' }
    end

    def self.validate_against_input(klass)
      klass.input :validate_against,
                  title: 'Validate Against',
                  optional: true,
                  type: 'checkbox',
                  default: %w[au_ps_bundle],
                  options: { list_options: validate_against_options }
    end

    def self.validate_against_options
      [
        { label: 'AU PS Bundle Validation', value: 'au_ps_bundle' },
        { label: 'IPS Bundle Validation', value: 'ips_bundle' }
      ]
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
        when 'url' then CommonInputsModule.configure_retrieve_client(self)
        when 'summary_op' then CommonInputsModule.configure_summary_client(self)
        end
      end
    end

    def self.configure_retrieve_client(client)
      client.url :url_retrieve
      client.oauth_credentials :credentials_retrieve
      client.headers(build_headers(client.header_name_retrieve, client.header_value_retrieve))
    end

    def self.configure_summary_client(client)
      client.url :url_sum
      client.oauth_credentials :credentials_sum
      client.headers(build_headers(client.header_name_sum, client.header_value_sum))
    end

    def self.build_headers(name, value)
      name.present? && value.present? ? { name => value } : {}
    end
  end
end
