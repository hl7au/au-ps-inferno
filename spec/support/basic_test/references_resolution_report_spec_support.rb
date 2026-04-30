# frozen_string_literal: true

RSpec.shared_context 'references resolution report setup' do
  let(:test_class) do
    Class.new(AUPSTestKit::BasicTest) do
      attr_accessor :metadata_manager
    end
  end
  let(:test_instance) { test_class.new }

  def build_bundle(section_code:, references:, resources:)
    raw = JSON.parse(
      JSON.generate(
        {
          resourceType: 'Bundle',
          type: 'document',
          entry: [
            {
              fullUrl: 'urn:uuid:composition-1',
              resource: {
                resourceType: 'Composition',
                status: 'final',
                type: { coding: [{ code: '60591-5' }] },
                subject: { reference: 'urn:uuid:patient-1' },
                date: '2024-01-01T00:00:00Z',
                author: [{ reference: 'urn:uuid:author-1' }],
                title: 'Test Composition',
                section: [
                  {
                    code: { coding: [{ code: section_code }] },
                    entry: references.map { |ref| { reference: ref } }
                  }
                ]
              }
            },
            { fullUrl: 'urn:uuid:patient-1', resource: { resourceType: 'Patient' } },
            { fullUrl: 'urn:uuid:author-1', resource: { resourceType: 'Practitioner' } },
            *resources
          ]
        }
      )
    )
    BundleDecorator.new(FHIR::Bundle.new(raw))
  end
end
