# frozen_string_literal: true

require 'fhir_models'

require_relative '../../lib/au_ps_inferno/utils/address_country_check'

RSpec.describe AUPSTestKit::AddressCountryCheck do
  # Stub the metadata-derived paths directly so the spec doesn't depend on (or drift with)
  # the real generated metadata.yaml.
  before do
    described_class.instance_variable_set(:@address_paths_by_resource_type,
                                          { 'Patient' => %w[address contact.address],
                                            'Organization' => ['address'] })
  end

  after do
    described_class.instance_variable_set(:@address_paths_by_resource_type, nil)
  end

  def bundle_with(*resources)
    FHIR::Bundle.new(
      resourceType: 'Bundle',
      type: 'document',
      entry: resources.map { |resource| { fullUrl: "urn:uuid:#{resource.id}", resource: resource } }
    )
  end

  def patient_with_address(id:, country:)
    FHIR::Patient.new(resourceType: 'Patient', id: id, address: [{ country: country }])
  end

  it 'returns no messages when every address country is "AU"' do
    bundle = bundle_with(patient_with_address(id: 'p1', country: 'AU'))

    expect(described_class.messages_for(bundle)).to eq([])
  end

  it 'returns no messages when country is absent' do
    bundle = bundle_with(FHIR::Patient.new(resourceType: 'Patient', id: 'p1', address: [{ city: 'Sydney' }]))

    expect(described_class.messages_for(bundle)).to eq([])
  end

  it 'warns when country is a full country name' do
    bundle = bundle_with(patient_with_address(id: 'p1', country: 'Australia'))

    messages = described_class.messages_for(bundle)

    expect(messages.length).to eq(1)
    expect(messages.first[:type]).to eq('warning')
    expect(messages.first[:message]).to include('Patient/p1').and include('"Australia"')
  end

  it 'warns when country is the alpha-3 code' do
    bundle = bundle_with(patient_with_address(id: 'p1', country: 'AUS'))

    expect(described_class.messages_for(bundle).length).to eq(1)
  end

  it 'warns once per offending address, referencing the correct index' do
    patient = FHIR::Patient.new(
      resourceType: 'Patient',
      id: 'p1',
      address: [{ country: 'AU' }, { country: 'Australia' }]
    )
    bundle = bundle_with(patient)

    messages = described_class.messages_for(bundle)

    expect(messages.length).to eq(1)
    expect(messages.first[:message]).to include('address[1]')
  end

  it 'walks nested paths from metadata (e.g. Patient.contact.address)' do
    patient = FHIR::Patient.new(
      resourceType: 'Patient',
      id: 'p1',
      contact: [{ address: { country: 'Australia' } }]
    )
    bundle = bundle_with(patient)

    messages = described_class.messages_for(bundle)

    expect(messages.length).to eq(1)
    expect(messages.first[:message]).to include('contact.address[0]')
  end

  it 'covers more than one resource type, not just Patient' do
    organization = FHIR::Organization.new(resourceType: 'Organization', id: 'org1', address: [{ country: 'AUS' }])
    bundle = bundle_with(organization)

    messages = described_class.messages_for(bundle)

    expect(messages.length).to eq(1)
    expect(messages.first[:message]).to include('Organization/org1')
  end

  it 'returns no messages for a resource type not covered by au-address metadata' do
    practitioner = FHIR::Practitioner.new(resourceType: 'Practitioner', id: 'pr1', address: [{ country: 'Australia' }])
    bundle = bundle_with(practitioner)

    expect(described_class.messages_for(bundle)).to eq([])
  end

  it 'returns no messages for a non-Bundle resource' do
    patient = patient_with_address(id: 'p1', country: 'Australia')

    expect(described_class.messages_for(patient)).to eq([])
  end
end
