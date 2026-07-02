# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/generator/naming'

RSpec.describe Generator::Naming do
  describe '.reformatted_version' do
    it 'strips dots and hyphens' do
      expect(described_class.reformatted_version('1.0.0-preview')).to eq('100preview')
      expect(described_class.reformatted_version('1.0.0-ballot')).to eq('100ballot')
      expect(described_class.reformatted_version('1.0.0')).to eq('100')
    end
  end

  describe '.versioned_class_name' do
    it 'appends the suffix directly with no separator' do
      expect(described_class.versioned_class_name('AUPSBundleInstance', '100preview'))
        .to eq('AUPSBundleInstance100preview')
    end

    it 'returns the base unchanged when the suffix is empty' do
      expect(described_class.versioned_class_name('AUPSBundleInstance', '')).to eq('AUPSBundleInstance')
    end
  end

  describe '.versioned_id' do
    it 'appends the suffix with an underscore separator' do
      expect(described_class.versioned_id('au_ps_bundle_instance', '100preview'))
        .to eq('au_ps_bundle_instance_100preview')
    end

    it 'returns the base unchanged when the suffix is empty' do
      expect(described_class.versioned_id('au_ps_bundle_instance', '')).to eq('au_ps_bundle_instance')
    end

    it 'accepts symbols for the base' do
      expect(described_class.versioned_id(:au_ps_bundle_instance, '100preview'))
        .to eq('au_ps_bundle_instance_100preview')
    end
  end
end
