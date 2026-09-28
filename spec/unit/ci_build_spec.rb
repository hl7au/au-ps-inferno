# frozen_string_literal: true

require 'json'
require 'rubygems/package'
require 'stringio'
require 'tmpdir'
require 'zlib'

require_relative '../../rakelib/ci_build'

RSpec.describe AUPSTestKit::CIBuild do
  subject(:ci_build) { described_class.new(root:) }

  let(:root) { Dir.mktmpdir('au_ps_ci_build_spec') }
  let(:config_path) { File.join(root, 'config.ci-build.json') }
  let(:manifest_url) { 'https://build.fhir.org/ig/hl7au/au-fhir-ps/package.manifest.json' }
  let(:package_url) { 'https://build.fhir.org/ig/hl7au/au-fhir-ps/package.tgz' }
  let(:new_package) { { 'name' => 'hl7.fhir.au.ps', 'version' => '1.0.2-ci-build', 'date' => '20261001000000' } }

  before { FileUtils.cp(File.expand_path('../../config.ci-build.json', __dir__), config_path) }
  after { FileUtils.remove_entry(root) }

  def package_tgz(package_json)
    tar = StringIO.new
    Gem::Package::TarWriter.new(tar) do |writer|
      body = JSON.generate(package_json)
      writer.add_file_simple('package/package.json', 0o644, body.bytesize) { |io| io.write(body) }
    end
    gzip = StringIO.new
    Zlib::GzipWriter.wrap(gzip) { |writer| writer.write(tar.string) }
    gzip.string
  end

  def stub_manifest(date)
    stub_request(:get, manifest_url).to_return(body: JSON.generate('version' => '1.0.2-ci-build', 'date' => date))
  end

  it 'reads the recorded CI build from config.ci-build.json' do
    expect(ci_build.version).to end_with('-ci-build')
    expect(ci_build.recorded_date).to match(/\A\d{14}\z/)
    expect(ci_build.package_path).to eq(File.join(root, 'lib/au_ps_inferno/igs/ci-build.tgz'))
  end

  it 'has changed only while the published manifest date differs from the recorded one' do
    stub_manifest(ci_build.recorded_date)
    expect(ci_build.changed?).to be(false)

    stub_manifest('20261001000000')
    expect(ci_build.changed?).to be(true)
  end

  it 'records the version and date of the package it downloaded' do
    stub_request(:get, package_url).to_return(body: package_tgz(new_package))

    ci_build.download

    expect(File).to exist(ci_build.package_path)
    expect(ci_build.version).to eq('1.0.2-ci-build')
    expect(ci_build.recorded_date).to eq('20261001000000')
    expect(JSON.parse(File.read(config_path)).dig('ci_build', 'manifest_url')).to eq(manifest_url)
  end

  it 'refuses a package that is not a ci-build version, writing nothing to the config' do
    stub_request(:get, package_url).to_return(body: package_tgz(new_package.merge('version' => '1.1.0')))
    before = File.read(config_path)

    expect { ci_build.download }.to raise_error(described_class::Error, /expected a version ending in -ci-build/)
    expect(File.read(config_path)).to eq(before)
  end

  describe '#refresh' do
    it 'does nothing while the CI build is unchanged' do
      stub_manifest(ci_build.recorded_date)

      expect { |generate| ci_build.refresh(&generate) }.not_to yield_control
    end

    it 'regenerates regardless when forced' do
      stub_request(:get, package_url).to_return(body: package_tgz(new_package))

      expect { |generate| expect(ci_build.refresh(force: true, &generate)).to be(true) }.to yield_control
    end

    it 'puts the config back when generation fails' do
      stub_manifest('20261001000000')
      stub_request(:get, package_url).to_return(body: package_tgz(new_package))
      before = File.read(config_path)

      expect { ci_build.refresh { raise 'generator failed' } }.to raise_error('generator failed')
      expect(File.read(config_path)).to eq(before)
    end
  end

  describe '#ensure_package!' do
    it 'accepts the package the config records' do
      stub_request(:get, package_url).to_return(body: package_tgz(new_package))
      ci_build.download

      expect { ci_build.ensure_package! }.not_to raise_error
    end

    it 'refuses a missing or stale local package' do
      expect { ci_build.ensure_package! }.to raise_error(described_class::Error, /missing/)

      FileUtils.mkdir_p(File.dirname(ci_build.package_path))
      File.binwrite(ci_build.package_path, package_tgz(new_package.merge('date' => '20200101000000')))
      expect { ci_build.ensure_package! }.to raise_error(described_class::Error, /records/)
    end
  end
end
