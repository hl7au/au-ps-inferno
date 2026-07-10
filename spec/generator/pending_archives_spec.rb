# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/generator/pending_archives'

RSpec.describe Generator::PendingArchives do
  let(:igs_dir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(igs_dir) }

  it 'lists every .tgz archive that has never been generated' do
    File.write(File.join(igs_dir, '1.0.0.tgz'), 'a')
    File.write(File.join(igs_dir, '1.1.0.tgz'), 'b')

    expect(described_class.new(igs_dir).list).to contain_exactly(
      File.join(igs_dir, '1.0.0.tgz'), File.join(igs_dir, '1.1.0.tgz')
    )
  end

  it 'excludes an archive once it has been recorded with its current content' do
    archive = File.join(igs_dir, '1.0.0.tgz')
    File.write(archive, 'a')
    Generator::GeneratedManifest.new(igs_dir).record(archive, '1.0.0')

    expect(described_class.new(igs_dir).list).to eq([])
  end

  it 're-includes an archive whose content changed since it was recorded' do
    archive = File.join(igs_dir, '1.0.0.tgz')
    File.write(archive, 'a')
    Generator::GeneratedManifest.new(igs_dir).record(archive, '1.0.0')
    File.write(archive, 'a-changed')

    expect(described_class.new(igs_dir).list).to eq([archive])
  end

  it 'ignores non-.tgz files' do
    File.write(File.join(igs_dir, 'notes.txt'), 'a')

    expect(described_class.new(igs_dir).list).to eq([])
  end
end
