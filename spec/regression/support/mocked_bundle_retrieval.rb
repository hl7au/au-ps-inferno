# frozen_string_literal: true

require 'webmock/rspec'

# Stubs the direct-URL bundle retrieval GET made by RetrieveBundleTestClass,
# serving a vendored fixture file's bytes instead of the real upstream URL.
module MockedBundleRetrievalSupport
  def stub_bundle_retrieval!(url:, fixture_path:)
    stub_request(:get, url)
      .to_return(
        status: 200,
        body: File.read(fixture_path),
        headers: { 'Content-Type' => 'application/fhir+json' }
      )
  end
end
