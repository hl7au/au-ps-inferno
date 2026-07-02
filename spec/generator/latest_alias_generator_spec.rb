# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/generator/latest_alias_generator'

RSpec.describe Generator::LatestAliasGenerator do
  describe '#version_sort_key (private)' do
    def sort_key(version)
      described_class.new.send(:version_sort_key, version)
    end

    it 'ranks a final release above its prereleases' do
      expect(sort_key('1.0.0')).to be > sort_key('1.0.0-preview')
      expect(sort_key('1.0.0')).to be > sort_key('1.0.0-ballot')
    end

    it 'ranks a higher numeric version above a lower one regardless of prerelease tag' do
      expect(sort_key('1.1.0-preview')).to be > sort_key('1.0.0')
    end

    it 'falls back to the raw string when Gem::Version cannot parse it' do
      expect(sort_key('not-a-version')).to eq('not-a-version')
    end
  end
end
