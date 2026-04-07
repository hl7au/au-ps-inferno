# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'shellwords'

SNAPSHOT_DIR = File.expand_path('../fixtures/snapshots/suite_100ballot', __dir__)
UPDATE_SNAPSHOTS = ENV['UPDATE_SNAPSHOTS'] == '1'
BUNDLE_CASES = [
  {
    name: 'basicsummary',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-basicsummary.json',
    snapshot: 'basicsummary.snapshot.txt'
  },
  {
    name: 'gpvisit-retrieval',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-gpvisit-retrieval.json',
    snapshot: 'gpvisit-retrieval.snapshot.txt'
  },
  {
    name: 'noknownx',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-noknownx.json',
    snapshot: 'noknownx.snapshot.txt'
  },
  {
    name: 'referral-endoconsult-autogen',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-referral-endoconsult-autogen.json',
    snapshot: 'referral-endoconsult-autogen.snapshot.txt'
  },
  {
    name: 'referral-endoconsult-curated',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-referral-endoconsult-curated.json',
    snapshot: 'referral-endoconsult-curated.snapshot.txt'
  },
  {
    name: 'section-emptyreason',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-section-emptyreason.json',
    snapshot: 'section-emptyreason.snapshot.txt'
  }
].freeze
EXECUTE_COMMAND = ENV.fetch(
  'SNAPSHOT_INFERNO_EXECUTE_COMMAND',
  'bundle exec inferno execute'
).freeze

RSpec.describe 'suite_100ballot snapshots' do
  def run_suite(bundle_url)
    command = [
      *Shellwords.split(EXECUTE_COMMAND),
      '--suite', 'suite_100ballot',
      '--inputs', "bundle_url:#{bundle_url}"
    ]

    output, _status = Open3.capture2e(*command)
    raise "Command produced no output for #{bundle_url}" if output.strip.empty?

    output
  end

  def normalize_output(raw_output)
    normalized = raw_output.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    normalized = normalized.gsub(/\e\[[\d;]*m/, '')
    lines = normalized.gsub("\r\n", "\n").gsub("\r", "\n").lines.map(&:rstrip)

    start_index = lines.index { |line| line.include?('Test Results:') }
    raise 'Could not find "Test Results:" section in command output' if start_index.nil?

    summary_lines = lines[start_index..]
    end_index = summary_lines.rindex { |line| line.match?(/^=+$/) }
    raise 'Could not find closing separator line in command output' if end_index.nil?

    summary_lines = summary_lines[..end_index]
    summary_lines
      .grep_v(/^\s*$/)
      .join("\n")
      .concat("\n")
  end

  def assert_or_update_snapshot(snapshot_file, content)
    FileUtils.mkdir_p(File.dirname(snapshot_file))
    if UPDATE_SNAPSHOTS
      File.write(snapshot_file, content)
      return
    end

    unless File.exist?(snapshot_file)
      raise "Snapshot not found: #{snapshot_file}. Run with UPDATE_SNAPSHOTS=1 to create it."
    end

    expected = File.read(snapshot_file)
    expect(content).to eq(expected)
  end

  BUNDLE_CASES.each do |test_case|
    it "matches snapshot for #{test_case[:name]}" do
      raw_output = run_suite(test_case[:url])
      normalized_output = normalize_output(raw_output)
      snapshot_path = File.join(SNAPSHOT_DIR, test_case[:snapshot])

      assert_or_update_snapshot(snapshot_path, normalized_output)
    end
  end
end
