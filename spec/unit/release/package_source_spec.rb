# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/release/package_source'

RSpec.describe Release::PackageSource do
  let(:config) do
    {
      'ig_id' => 'hl7.fhir.au.ps',
      'registries' => ['https://packages.fhir.org'],
      'destination' => 'lib/au_ps_inferno/igs',
      'ignore_list' => 'does/not/exist.yml'
    }
  end
  let(:source) { described_class.new(config: config) }
  let(:manager) { instance_double(FhirPackagesManager::Manager) }

  before do
    allow(FhirPackagesManager::Manager).to receive(:new).and_return(manager)
  end

  def fetch_result(version:, status:, path: nil)
    FhirPackagesManager::FetchResult.new(
      package: FhirPackagesManager::Package.new('hl7.fhir.au.ps', version),
      status: status,
      path: path
    )
  end

  describe '#sync_all' do
    it 'syncs the configured ig_id against the configured registries/destination' do
      expect(FhirPackagesManager::Manager).to receive(:new).with(
        registries: ['https://packages.fhir.org'],
        destination: 'lib/au_ps_inferno/igs',
        ignore_list: nil
      ).and_return(manager)
      allow(manager).to receive(:sync).with('hl7.fhir.au.ps').and_return([])

      source.sync_all
    end

    it 'returns downloaded and skipped (already on disk) versions, sorted by version' do
      allow(manager).to receive(:sync).and_return([
        fetch_result(version: '1.1.0-ballot', status: :downloaded, path: 'igs/hl7.fhir.au.ps-1.1.0-ballot.tgz'),
        fetch_result(version: '1.0.0', status: :skipped, path: 'igs/hl7.fhir.au.ps-1.0.0.tgz')
      ])

      expect(source.sync_all).to eq([
        Release::PackageSource::Downloaded.new(version: '1.0.0', path: 'igs/hl7.fhir.au.ps-1.0.0.tgz'),
        Release::PackageSource::Downloaded.new(version: '1.1.0-ballot', path: 'igs/hl7.fhir.au.ps-1.1.0-ballot.tgz')
      ])
    end

    it 'excludes ignored and not_found versions, which carry no usable path' do
      allow(manager).to receive(:sync).and_return([
        fetch_result(version: '0.1.0-preview', status: :ignored),
        fetch_result(version: '9.9.9', status: :not_found)
      ])

      expect(source.sync_all).to eq([])
    end
  end

  describe 'ignore_list handling' do
    it 'passes nil when the configured ignore_list file does not exist' do
      expect(FhirPackagesManager::Manager).to receive(:new)
        .with(hash_including(ignore_list: nil)).and_return(manager)
      allow(manager).to receive(:sync).and_return([])

      source.sync_all
    end

    it 'loads the ignore_list file when it exists' do
      ignore_list = instance_double(FhirPackagesManager::IgnoreList)
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('present.yml').and_return(true)
      allow(FhirPackagesManager::IgnoreList).to receive(:load).with('present.yml').and_return(ignore_list)
      allow(manager).to receive(:sync).and_return([])

      described_source = described_class.new(config: config.merge('ignore_list' => 'present.yml'))

      expect(FhirPackagesManager::Manager).to receive(:new)
        .with(hash_including(ignore_list: ignore_list)).and_return(manager)

      described_source.sync_all
    end
  end
end
