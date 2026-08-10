# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require_relative '../../../lib/au_ps_inferno/release/main_file_writer'

RSpec.describe Release::MainFileWriter do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  let(:main_file_path) { File.join(@dir, 'au_ps_inferno.rb') }
  let(:generated_root) { File.join(@dir, 'generated') }
  let(:writer) { described_class.new(main_file_path: main_file_path, generated_root: generated_root) }

  def write_main_file(content)
    File.write(main_file_path, content)
  end

  def touch_generated_suite(version)
    dir = File.join(generated_root, version)
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, 'suite.rb'), '# stub')
  end

  def main_file_content
    File.read(main_file_path)
  end

  it 'preserves hand-written requires above the marker and never touches them' do
    write_main_file(<<~RUBY)
      # frozen_string_literal: true

      require_relative 'au_ps_inferno/suite/au_ps_v100'
      require_relative 'au_ps_inferno/suite/au_ps_v100_single_file'
    RUBY

    writer.write!

    expect(main_file_content).to include("require_relative 'au_ps_inferno/suite/au_ps_v100'\n")
    expect(main_file_content).to include("require_relative 'au_ps_inferno/suite/au_ps_v100_single_file'\n")
  end

  it 'appends a require for every generated suite folder, sorted by version' do
    write_main_file("# frozen_string_literal: true\n")
    touch_generated_suite('1.1.0-ballot')
    touch_generated_suite('1.0.0')

    writer.write!

    expect(main_file_content).to include(<<~RUBY)
      # BEGIN GENERATED RELEASE SUITES (auto-managed by `make new_release` -- do not edit by hand)
      require_relative 'au_ps_inferno/generated/1.0.0/suite'
      require_relative 'au_ps_inferno/generated/1.1.0-ballot/suite'
      # END GENERATED RELEASE SUITES
    RUBY
  end

  it 'skips generated folders that have no suite.rb yet' do
    write_main_file("# frozen_string_literal: true\n")
    FileUtils.mkdir_p(File.join(generated_root, 'partial-download'))
    touch_generated_suite('1.0.0')

    writer.write!

    expect(main_file_content).not_to include('partial-download')
    expect(main_file_content).to include("au_ps_inferno/generated/1.0.0/suite'")
  end

  it 'is idempotent: re-running replaces the old block instead of duplicating it' do
    write_main_file("# frozen_string_literal: true\n")
    touch_generated_suite('1.0.0')
    writer.write!

    touch_generated_suite('1.1.0-ballot')
    writer.write!

    expect(main_file_content.scan('BEGIN GENERATED RELEASE SUITES').size).to eq(1)
    expect(main_file_content).to include("au_ps_inferno/generated/1.0.0/suite'")
    expect(main_file_content).to include("au_ps_inferno/generated/1.1.0-ballot/suite'")
  end

  it 'writes an empty marker block when nothing has been generated yet' do
    write_main_file("# frozen_string_literal: true\n")

    writer.write!

    expect(main_file_content).to include(<<~RUBY)
      # BEGIN GENERATED RELEASE SUITES (auto-managed by `make new_release` -- do not edit by hand)
      # END GENERATED RELEASE SUITES
    RUBY
  end
end
