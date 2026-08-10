# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/release/version_naming'

RSpec.describe Release::VersionNaming do
  describe '.reformatted' do
    it 'strips dots and turns dashes into underscores' do
      expect(described_class.reformatted('1.0.0')).to eq('v100')
    end

    it 'handles pre-release suffixes' do
      expect(described_class.reformatted('1.1.0-ballot')).to eq('v110_ballot')
    end
  end

  describe '.suite_id' do
    it 'builds a namespaced symbol so it can never collide with a hand-written suite id' do
      expect(described_class.suite_id('1.0.0')).to eq(:au_ps_release_v100)
    end
  end

  describe '.suite_constant_name' do
    it 'builds an upcased PascalCase constant name' do
      expect(described_class.suite_constant_name('1.1.0-ballot')).to eq('AUPSSuiteReleaseV110_BALLOT')
    end
  end

  describe '.folder_name' do
    it 'keeps the raw version string' do
      expect(described_class.folder_name('1.1.0-ballot')).to eq('1.1.0-ballot')
    end
  end
end
