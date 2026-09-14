# frozen_string_literal: true

require_relative 'basic_test_class'
require_relative 'common_inputs_module'

module AUPSTestKit
  # Loads a Bundle pasted as text, or fetched by ID from a FHIR server, into the
  # group's scratch space
  class ProvidedBundleTestClass < BasicTest
    id :provided_bundle_test_class

    NO_PROVIDED_BUNDLE_MESSAGE = 'No Bundle resource was provided, so this test group is omitted.'
    NO_FHIR_BUNDLE_ID_MESSAGE = 'No FHIR server URL with a Bundle ID was provided, so this test group is omitted.'

    CommonInputsModule.bundle_resource_or_fhir_bundle_id_inputs(self)

    def parse_bundle_resource
      FHIR.from_contents(bundle_resource)
    rescue StandardError
      nil
    end

    def skip_fhir_bundle_id_test?
      url.blank? || bundle_id.blank?
    end

    def load_provided_bundle_resource
      resource = parse_bundle_resource
      assert resource.present?, 'The provided text could not be parsed as a FHIR resource'
      assert resource.resourceType == 'Bundle',
             "The provided resource is a #{resource.resourceType}, expected a Bundle"
      save_bundle_to_scratch(resource)
    end

    def load_bundle_resource_from_fhir_server
      fhir_read(:bundle, bundle_id)
      assert_response_status(200)
      assert_resource_type(:bundle)
      save_bundle_to_scratch(resource)
    end

    # A different pathway from bundle_resource is used only once the suite-wide radio
    # is explicitly set to 'fhir_server'; this keeps a stale bundle_resource value from
    # a previous run from being validated instead of fetching the current server Bundle,
    # matching how the other acquisition classes ignore fields outside their own method.
    #
    # A bare bundle_id is rejected by GenerateSummaryBundleTestClass's own group (it omits
    # itself whenever a Bundle ID is present), so this group is the sole owner of Bundle ID
    # retrieval and never needs to defer to it.
    run do
      omit_unless_retrieve_method_is('bundle_resource', 'fhir_server')

      if bundle_retrieve_method == 'fhir_server'
        omit_if skip_fhir_bundle_id_test?, NO_FHIR_BUNDLE_ID_MESSAGE
        load_bundle_resource_from_fhir_server
      else
        omit_if bundle_resource.blank?, NO_PROVIDED_BUNDLE_MESSAGE
        load_provided_bundle_resource
      end
    end
  end
end
