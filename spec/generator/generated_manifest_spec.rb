# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/generator/generated_manifest'

RSpec.describe Generator::GeneratedManifest do
  let(:igs_dir) { Dir.mktmpdir }
  let(:archive_path) { File.join(igs_dir, '1.1.0.tgz') }

  before { File.write(archive_path, 'fake archive content') }
  after { FileUtils.rm_rf(igs_dir) }

  describe '#changed?' do
    it 'is true for an archive that has never been recorded' do
      expect(described_class.new(igs_dir).changed?(archive_path)).to be true
    end

    it 'is false once the exact same content has been recorded' do
      manifest = described_class.new(igs_dir)
      manifest.record(archive_path, '1.1.0')

      expect(described_class.new(igs_dir).changed?(archive_path)).to be false
    end

    it 'is true again if the archive content changes after being recorded' do
      manifest = described_class.new(igs_dir)
      manifest.record(archive_path, '1.1.0')
      File.write(archive_path, 'different content')

      expect(described_class.new(igs_dir).changed?(archive_path)).to be true
    end
  end

  describe '#record' do
    it 'persists the archive basename, checksum, ig_version, and generation date' do
      described_class.new(igs_dir).record(archive_path, '1.1.0')

      entries = described_class.new(igs_dir).entries
      entry = entries.find { |e| e['archive'] == '1.1.0.tgz' }

      expect(entry['sha256']).to eq(Digest::SHA256.file(archive_path).hexdigest)
      expect(entry['ig_version']).to eq('1.1.0')
      expect(entry['generated_at']).to match(/\A\d{4}-\d{2}-\d{2}\z/)
    end

    it 'replaces a prior entry for the same archive rather than duplicating it' do
      manifest = described_class.new(igs_dir)
      manifest.record(archive_path, '1.1.0')
      manifest.record(archive_path, '1.1.0')

      expect(manifest.entries.count { |e| e['archive'] == '1.1.0.tgz' }).to eq(1)
    end

    it 'does not clobber a concurrently recorded entry for a different archive' do
      other_archive_path = File.join(igs_dir, '1.2.0.tgz')
      File.write(other_archive_path, 'other fake archive content')

      # Simulates two CI matrix jobs, each with its own process-local manifest instance,
      # recording different archives without seeing each other's writes.
      described_class.new(igs_dir).record(archive_path, '1.1.0')
      described_class.new(igs_dir).record(other_archive_path, '1.2.0')

      entries = described_class.new(igs_dir).entries
      expect(entries.map { |e| e['archive'] }).to contain_exactly('1.1.0.tgz', '1.2.0.tgz')
    end
  end
end
