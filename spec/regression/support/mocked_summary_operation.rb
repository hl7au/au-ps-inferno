# frozen_string_literal: true

require 'webmock/rspec'

# Stubs the IPS $summary operation GET made by GenerateSummaryBundleTestClass,
# matching the exact path/query it builds (see #operation_path in
# lib/au_ps_inferno/utils/generate_summary_bundle_test_class.rb), and serving
# a vendored fixture file's bytes as the response instead of a real server.
module MockedSummaryOperationSupport
  def stub_summary_operation!(base_url:, patient_id:, profile:, fixture_path:)
    stub_request(:get, "#{base_url}/Patient/#{patient_id}/$summary")
      .with(query: { 'profile' => profile })
      .to_return(
        status: 200,
        body: File.read(fixture_path),
        headers: { 'Content-Type' => 'application/fhir+json' }
      )
  end
end
