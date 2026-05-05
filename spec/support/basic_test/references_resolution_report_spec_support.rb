# frozen_string_literal: true

require_relative 'fhir_bundle_helpers'
require_relative 'basic_test_instance_setup'

RSpec.shared_context 'references resolution report setup' do
  include FhirBundleHelpers
  include_context 'basic test instance setup'

  def build_bundle(section_code:, references:, bundle_entries:)
    sections = [{ code: { coding: [{ code: section_code }] }, entry: references.map { |ref| { reference: ref } } }]
    author_entry = FHIR::Bundle::Entry.new(fullUrl: 'urn:uuid:author-1', resource: FHIR::Practitioner.new)
    BundleDecorator.new(build_fhir_bundle(sections: sections, extra_entries: [author_entry, *bundle_entries]))
  end
end
