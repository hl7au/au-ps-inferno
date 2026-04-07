# frozen_string_literal: true

require_relative '../../../spec_helper'
require_relative '../../../support/generator_metadata_manager_fixtures'

require_relative '../../../../lib/au_ps_inferno/generator/generator'

# rubocop:disable Metrics/BlockLength -- covers public API and orchestration of Generator
RSpec.describe Generator do
  describe '.suite_version_from_ig_path' do
    it 'returns empty string for blank path' do
      expect(described_class.suite_version_from_ig_path('')).to eq('')
      expect(described_class.suite_version_from_ig_path('   ')).to eq('')
    end

    it 'derives version from basename stripping .tgz' do
      expect(described_class.suite_version_from_ig_path('/a/b/1.0.0-preview.tgz')).to eq('1.0.0-preview')
    end

    it 'derives version from basename stripping .tar.gz' do
      expect(described_class.suite_version_from_ig_path('pkg/2.1.0.tar.gz')).to eq('2.1.0')
    end

    it 'strips bare .tar when present' do
      expect(described_class.suite_version_from_ig_path('/x/0.9.0.tar')).to eq('0.9.0')
    end
  end

  describe '.version_suffix' do
    it 'returns empty string for blank version' do
      expect(described_class.version_suffix('')).to eq('')
      expect(described_class.version_suffix('   ')).to eq('')
    end

    it 'builds numeric and prerelease parts from a semver-like string' do
      expect(described_class.version_suffix('1.0.0-preview.tgz')).to eq('100preview')
    end

    it 'handles versions without prerelease' do
      expect(described_class.version_suffix('0.5.0')).to eq('050')
    end
  end

  describe '#initialize' do
    let(:extractor) { instance_double(Generator::IGResourcesExtractor, extract: nil, ig_resources: []) }

    before do
      allow(Generator::IGResourcesExtractor).to receive(:new).and_return(extractor)
    end

    it 'passes additional_resources_path to IGResourcesExtractor when given' do
      extra = '/path/to/extra-resources'
      expect(Generator::IGResourcesExtractor).to receive(:new).with(
        '/ig/package.tgz',
        additional_resources_path: extra
      ).and_return(extractor)

      described_class.new('/ig/package.tgz', additional_resources_path: extra)
    end

    it 'passes nil additional_resources_path by default' do
      expect(Generator::IGResourcesExtractor).to receive(:new).with(
        '/ig/package.tgz',
        additional_resources_path: nil
      ).and_return(extractor)

      described_class.new('/ig/package.tgz')
    end
  end

  describe '#generate' do
    # Basename must yield suite folder name 1.0.0-preview (see suite_version_from_ig_path)
    let(:ig_path) { '/tmp/1.0.0-preview.tgz' }
    let(:fixture_resources) { GeneratorMetadataManagerFixtures.full_ig_resources }
    let(:extractor) { instance_double(Generator::IGResourcesExtractor, extract: nil, ig_resources: fixture_resources) }
    let(:retrieve_gen) { instance_double(Generator::RetrieveCSGroupGenerator) }

    # Real initiated metadata so TestConfigRegistry lambdas (sections, MS elements, etc.) succeed.
    def inject_initiated_metadata!(instance, resources)
      meta = Generator::MetadataManager.new(resources)
      meta.initiate_build
      instance.instance_variable_set(:@metadata, meta)
      instance
    end

    let(:generator) { inject_initiated_metadata!(described_class.new(ig_path), fixture_resources) }

    before do
      allow(Generator::IGResourcesExtractor).to receive(:new).and_return(extractor)
      allow_any_instance_of(Generator::MetadataManager).to receive(:save_to_file)
      allow_any_instance_of(Generator::PrimitiveGroup).to receive(:generate).and_return(
        { path: 'ho_sub/prim', id: :primitive_group_id }
      )
      allow_any_instance_of(Generator::PrimitiveTest).to receive(:generate)
      allow_any_instance_of(Generator::HighOrderGroup).to receive(:generate).and_return(
        { path: 'ver/ho_file', id: :high_order_id }
      )
      allow_any_instance_of(Generator::SuitePrimitive).to receive(:generate).and_return(
        { path: 'lib/au_ps_inferno/ver/suite.rb', id: :suite_id }
      )

      allow(Generator::RetrieveCSGroupGenerator).to receive(:new).and_return(retrieve_gen)
      allow(retrieve_gen).to receive(:generate)
      allow(retrieve_gen).to receive(:suite_group_info).and_return(
        {
          file_path: 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group.rb',
          attributes: { group_id: 'au_ps_retrieve_cs_group_100preview' }
        }
      )
    end

    it 'extracts IG resources and completes suite generation' do
      expect(extractor).to receive(:extract)
      expect { generator.generate }.not_to raise_error
    end

    it 'persists metadata when suite version is non-empty' do
      path = File.expand_path(File.join('lib', 'au_ps_inferno', '1.0.0-preview', 'metadata.yaml'))
      meta = generator.instance_variable_get(:@metadata)
      expect(meta).to receive(:save_to_file).with(path)
      generator.generate
    end

    it 'does not persist metadata when suite version is empty' do
      empty_gen = inject_initiated_metadata!(described_class.new(''), fixture_resources)
      meta = empty_gen.instance_variable_get(:@metadata)
      expect(meta).not_to receive(:save_to_file)
      empty_gen.generate
    end

    it 'does not insert retrieve CS group when suite version is empty' do
      empty_gen = inject_initiated_metadata!(described_class.new(''), fixture_resources)
      expect(Generator::RetrieveCSGroupGenerator).not_to receive(:new)
      empty_gen.generate
    end

    it 'passes normalized and package IG versions to suite primitive config' do
      suite_primitive = instance_double(Generator::SuitePrimitive, generate: { path: 'x', id: :y })
      expect(Generator::SuitePrimitive).to receive(:new).with(
        hash_including(
          suite_version: '100preview',
          ig_package_version: '1.0.0-preview'
        )
      ).and_return(suite_primitive)

      generator.generate
    end
  end

  describe 'private helpers (via #send)' do
    let(:generator) { described_class.new('/x/1.0.0.tgz') }

    before do
      allow(Generator::IGResourcesExtractor).to receive(:new).and_return(
        instance_double(Generator::IGResourcesExtractor, extract: nil, ig_resources: [])
      )
    end

    describe '#validate_primitive_test_type!' do
      it 'raises for unknown test types' do
        expect do
          generator.send(:validate_primitive_test_type!, :not_a_registered_test_type)
        end.to raise_error(/Unknown test type id/)
      end

      it 'accepts :bundle_valid' do
        expect { generator.send(:validate_primitive_test_type!, :bundle_valid) }.not_to raise_error
      end

      it 'accepts registered test types' do
        expect { generator.send(:validate_primitive_test_type!, :bundle_must_support_populated) }.not_to raise_error
      end
    end

    describe '#ensure_bundle_valid_has_title!' do
      it 'raises when bundle_valid has no title' do
        expect do
          generator.send(:ensure_bundle_valid_has_title!, :bundle_valid, nil)
        end.to raise_error(/bundle_validation_title/)
      end

      it 'does not raise when title is present' do
        expect do
          generator.send(:ensure_bundle_valid_has_title!, :bundle_valid, 'T')
        end.not_to raise_error
      end
    end

    describe '#suite_group_info_to_path_id' do
      it 'strips .rb from path and symbolizes group id' do
        out = generator.send(:suite_group_info_to_path_id, {
                               file_path: 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group.rb',
                               attributes: { group_id: 'au_ps_retrieve_cs_group_100preview' }
                             })
        expect(out).to eq(
          path: 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group',
          id: :au_ps_retrieve_cs_group_100preview
        )
      end
    end

    describe '#ig_version_to_suite_version' do
      it 'removes dots and hyphens' do
        expect(generator.send(:ig_version_to_suite_version, '1.0.0-preview')).to eq('100preview')
      end
    end

    describe '#group_description' do
      it 'returns a validation sentence' do
        expect(generator.send(:group_description, 'AU PS Bundle')).to eq('Validates AU PS Bundle.')
      end
    end

    describe '#versioned_path' do
      it 'joins PATH_BASE, suite version, and segments' do
        g = described_class.new('/p/2.0.0.tgz')
        allow(Generator::IGResourcesExtractor).to receive(:new).and_return(
          instance_double(Generator::IGResourcesExtractor, extract: nil, ig_resources: [])
        )
        expect(g.send(:versioned_path, 'ho', 'nested', filename: 'file.rb')).to eq(
          File.join('lib/au_ps_inferno', '2.0.0', 'ho', 'nested', 'file.rb')
        )
      end
    end

    describe '#high_order_groups_with_relative_paths' do
      it 'replaces path with the final path segment' do
        groups = [{ path: 'lib/au_ps_inferno/1.0.0/foo/bar', id: :x }]
        expect(generator.send(:high_order_groups_with_relative_paths, groups)).to eq(
          [{ path: 'bar', id: :x }]
        )
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
