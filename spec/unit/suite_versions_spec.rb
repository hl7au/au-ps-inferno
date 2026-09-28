# frozen_string_literal: true

require 'json'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

require_relative '../../lib/au_ps_inferno'

RSpec.describe 'AU PS suite versions' do
  root_dir = File.expand_path('../..', __dir__)
  configs = Dir.glob(File.join(root_dir, 'inferno_suite_generator.config.*.json')).to_h do |path|
    [File.basename(path, '.json').delete_prefix('inferno_suite_generator.config.'), JSON.parse(File.read(path))]
  end

  def all_runnables(runnable)
    [runnable, *runnable.children.flat_map { |child| all_runnables(child) }]
  end

  def au_ps_suites
    Inferno::Repositories::TestSuites.new.all.select { |suite| suite.id.to_s.start_with?('au_ps_v') }
  end

  describe AUPSTestKit::SuiteVersion do
    it 'derives the suite id from the IG package version' do
      expect(described_class.suite_id_for('1.0.0')).to eq(:au_ps_v100)
      expect(described_class.suite_id_for('1.0.1-ci-build')).to eq(:au_ps_v101_ci_build)
      expect(described_class.suite_id_for('1.1.0-ballot')).to eq(:au_ps_v110_ballot)
    end

    it 'rejects anything that is not a package version' do
      expect { described_class.suite_id_for('current') }.to raise_error(ArgumentError)
      expect { described_class.suite_id_for('') }.to raise_error(ArgumentError)
    end

    it 'defaults the validator package to the package id at the IG version' do
      version = described_class.new(key: '1.0.0', ig_version: '1.0.0')

      expect(version.validator_package).to eq('hl7.fhir.au.ps#1.0.0')
      expect(version.metadata_path).to eq(File.join(root_dir, 'lib/au_ps_inferno/1.0.0/metadata.yaml'))
    end
  end

  describe 'generator configs' do
    it 'exist for at least the released version' do
      expect(configs.keys).to include('1.0.0')
    end

    it 'each yield a valid suite id, and no two yield the same one' do
      suite_ids = configs.values.map { |config| AUPSTestKit::SuiteVersion.suite_id_for(config.dig('ig', 'version')) }

      expect(suite_ids).to all(match(AUPSTestKit::SuiteVersion::SUITE_ID_PATTERN))
      expect(suite_ids.uniq.length).to eq(suite_ids.length)
    end

    configs.each do |key, config|
      context "for version #{key}" do
        let(:suite_file) { File.join(root_dir, config.dig('kit', 'suite_file')) }

        it 'has generated metadata in lib/au_ps_inferno/<key>/' do
          %w[metadata.yaml composition_metadata.yaml].each do |file|
            expect(File).to exist(File.join(root_dir, 'lib', 'au_ps_inferno', key, file))
          end
        end

        it 'names a suite class whose IG_VERSION matches the config' do
          expect(File.read(suite_file)).to include("IG_VERSION = '#{config.dig('ig', 'version')}'")
        end
      end
    end
  end

  describe 'registered suites' do
    it 'include au_ps_v100 for the released 1.0.0 IG' do
      suite = Inferno::Repositories::TestSuites.new.find('au_ps_v100')

      expect(suite::SUITE_VERSION).to eq(AUPSTestKit::SuiteVersion.new(key: '1.0.0', ig_version: '1.0.0'))
      expect(suite.fhir_validators[:default].first.igs).to eq(['hl7.fhir.au.ps#1.0.0'])
    end

    it 'hand every runnable the metadata and IG version of its own suite' do
      au_ps_suites.each do |suite|
        expected = suite::SUITE_VERSION.runnable_options

        all_runnables(suite).each do |runnable|
          expect(runnable.config.options).to include(expected), "#{runnable.id} lacks #{suite.id} options"
        end
      end
    end

    it 'resolve metadata and the bundle profile version per suite at run time' do
      au_ps_suites.each do |suite|
        tests = all_runnables(suite).select { |runnable| runnable < AUPSTestKit::BasicTest }.map { _1.new(scratch: {}) }

        expect(tests).not_to be_empty
        tests.each do |test|
          expect(test.metadata_manager.metadata_yaml_path).to eq(suite::SUITE_VERSION.metadata_path)
          expect(test.au_ps_ig_version).to eq(suite::SUITE_VERSION.ig_version)
        end
      end
    end

    it 'leave the shared group templates without suite options' do
      template = Inferno::Repositories::TestGroups.new.find('suite_au_ps_bundle_instance')

      expect(template.config.options).not_to include(:au_ps_metadata_path)
    end
  end

  describe 'two suite versions in one process' do
    # A second version defined only for this spec, standing in for the CI build or a new
    # release, so the spec proves coexistence without depending on which versions ship.
    let!(:second_suite) do
      Class.new(Inferno::TestSuite) do
        const_set(:SUITE_VERSION, AUPSTestKit::SuiteVersion.new(key: '1.0.0', ig_version: '0.0.1-coexistence-spec'))
        extend AUPSTestKit::AUPSSuiteDefinition

        define_au_ps_suite(self::SUITE_VERSION, title: 'Coexistence spec', description: 'Coexistence spec')
      end
    end
    let(:first_suite) { Inferno::Repositories::TestSuites.new.find('au_ps_v100') }

    after { second_suite.send(:remove_self_from_repository) }

    it 'gives every runnable of each suite an id and database id of its own' do
      first_ids = all_runnables(first_suite).flat_map { |runnable| [runnable.id.to_s, runnable.database_id.to_s] }
      second_ids = all_runnables(second_suite).flat_map { |runnable| [runnable.id.to_s, runnable.database_id.to_s] }

      expect(second_suite.id).to eq('au_ps_v001_coexistence_spec')
      expect(first_ids & second_ids).to be_empty
      expect(second_ids.length).to eq(first_ids.length)
    end

    it 'keeps each suite on its own validator package and options' do
      expect(second_suite.fhir_validators[:default].first.igs).to eq(['hl7.fhir.au.ps#0.0.1-coexistence-spec'])
      expect(all_runnables(first_suite).last.config.options[:au_ps_ig_version]).to eq('1.0.0')
      expect(all_runnables(second_suite).last.config.options[:au_ps_ig_version]).to eq('0.0.1-coexistence-spec')
    end
  end
end
