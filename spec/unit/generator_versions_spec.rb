# frozen_string_literal: true

require 'json'
require 'tmpdir'

require_relative '../../lib/au_ps_inferno/generator/generator'

RSpec.describe Generator do
  let(:root_dir) { Dir.mktmpdir('au_ps_generator_spec') }
  let(:suite_file) { 'lib/au_ps_inferno/suite/au_ps_v101_ci_build.rb' }

  after { FileUtils.remove_entry(root_dir) }

  def write_config(key, config)
    File.write(File.join(root_dir, "config.#{key}.json"), JSON.generate(config))
  end

  def config(version:, archive: nil, ci_build: false)
    {
      'kit' => { 'suite_file' => suite_file },
      'ig' => { 'id' => 'hl7.fhir.au.ps', 'version' => version, 'package_archive_path' => archive },
      'suite' => { 'title' => 'AU PS' },
      'ci_build' => ({ 'package_date' => '20261001000000' } if ci_build),
      'configs' => { 'generic' => {}, 'profiles' => {}, 'resources' => {} }
    }.compact
  end

  # A generator for +key+ in root_dir without loading an IG package.
  def bare_generator(key)
    described_class.allocate.tap do |generator|
      generator.instance_variable_set(:@version_key, key)
      generator.instance_variable_set(:@root_dir, root_dir)
    end
  end

  describe '.version_keys' do
    it 'lists the key of every per-version generator config' do
      write_config('1.0.0', config(version: '1.0.0'))
      write_config('ci-build', config(version: '1.0.1-ci-build'))

      expect(described_class.version_keys(root_dir)).to eq(%w[1.0.0 ci-build])
    end

    it 'finds the repository configs by default' do
      expect(described_class.version_keys).to include('1.0.0')
    end
  end

  describe '#initialize' do
    it 'refuses a version without a generator config' do
      expect { described_class.new(version_key: 'missing', root_dir:) }
        .to raise_error(ArgumentError, /No generator config for AU PS version "missing"/)
    end

    it 'refuses a version whose package archive is missing, rather than generating empty metadata' do
      write_config('ci-build', config(version: '1.0.1-ci-build', archive: 'lib/au_ps_inferno/igs/absent.tgz'))

      expect { described_class.new(version_key: 'ci-build', root_dir:) }
        .to raise_error(ArgumentError, /IG package archive for AU PS version "ci-build" not found/)
    end
  end

  describe '#update_suite_ig_version' do
    let(:generator) { bare_generator('ci-build') }
    let(:suite_path) { File.join(root_dir, suite_file) }

    before do
      write_config('ci-build', config(version: '1.0.1-ci-build'))
      FileUtils.mkdir_p(File.dirname(suite_path))
      File.write(suite_path, "class Suite\n  IG_VERSION = '1.0.1-ci-build'\nend\n")
    end

    it "rewrites only that version's suite class" do
      generator.send(:update_suite_ig_version, '1.0.2-ci-build')

      expect(File.read(suite_path)).to eq("class Suite\n  IG_VERSION = '1.0.2-ci-build'\nend\n")
    end

    it 'fails loudly when the suite class has no IG_VERSION constant' do
      File.write(suite_path, "class Suite\nend\n")

      expect { generator.send(:update_suite_ig_version, '1.0.2-ci-build') }
        .to raise_error(ArgumentError, /IG_VERSION constant not found/)
    end
  end

  describe '#write_ci_build_suite' do
    let(:generator) { bare_generator('ci-build') }
    let(:suite_path) { File.join(root_dir, suite_file) }

    before { write_config('ci-build', config(version: '1.0.1-ci-build', ci_build: true)) }

    it 'creates the suite class when it is absent, as on a ci-build branch freshly made from master' do
      generator.send(:write_ci_build_suite, '1.1.0-ci-build')

      expect(File.read(suite_path)).to eq(AUPSTestKit::CIBuildSuiteTemplate.source('1.1.0-ci-build'))
    end

    it 'replaces the whole class, not only IG_VERSION' do
      FileUtils.mkdir_p(File.dirname(suite_path))
      File.write(suite_path, "class Suite\n  IG_VERSION = '1.0.1-ci-build'\nend\n")

      generator.send(:write_ci_build_suite, '1.1.0-ci-build')

      expect(File.read(suite_path)).to eq(AUPSTestKit::CIBuildSuiteTemplate.source('1.1.0-ci-build'))
    end

    it 'refuses a package without a version rather than writing a class without one' do
      expect { generator.send(:write_ci_build_suite, nil) }.to raise_error(ArgumentError, /declares no version/)
      expect(File).not_to exist(suite_path)
    end
  end

  describe '#generate' do
    let(:suite_path) { File.join(root_dir, suite_file) }

    def generate(key, package_version)
      generator = bare_generator(key)
      generator.instance_variable_set(:@ig_resources, double(ig: double(version: package_version)))
      allow(generator).to receive(:save_metadata_to_version_folder)
      generator.generate
    end

    it 'writes the whole suite class for a CI build version' do
      write_config('ci-build', config(version: '1.0.1-ci-build', ci_build: true))

      generate('ci-build', '1.1.0-ci-build')

      expect(File.read(suite_path)).to eq(AUPSTestKit::CIBuildSuiteTemplate.source('1.1.0-ci-build'))
    end

    it "rewrites only IG_VERSION in a released version's hand-written class" do
      write_config('1.0.1', config(version: '1.0.1'))
      FileUtils.mkdir_p(File.dirname(suite_path))
      File.write(suite_path, "# hand-written\nclass Suite\n  IG_VERSION = '1.0.0'\nend\n")

      generate('1.0.1', '1.0.1')

      expect(File.read(suite_path)).to eq("# hand-written\nclass Suite\n  IG_VERSION = '1.0.1'\nend\n")
    end
  end
end
