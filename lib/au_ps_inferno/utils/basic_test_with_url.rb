# frozen_string_literal: true

module AUPSTestKit
  # A base class for all tests with FHIR server URL to decrease code duplication
  class BasicTestWithURL < BasicTest
    id :basic_test_with_url

    # The Capability Statement can only be meaningfully checked when the Bundle itself was
    # fetched from that same FHIR server, not merely because a URL happens to be filled in
    # (it could be a stale value left over from a different, non-fhir_server retrieval method).
    def omit_unless_fhir_server_bundle?
      omit_if bundle_retrieve_method != 'fhir_server' || url.blank?, NO_SERVER_URL_OMIT_MESSAGE
    end
  end
end
