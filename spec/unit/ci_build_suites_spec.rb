# frozen_string_literal: true

require 'open3'
require 'tmpdir'

require_relative '../../lib/au_ps_inferno/ci_build_suites'

# Runs everywhere: on master, where the CI build suite is absent, and on the ci-build branch and
# in the refresh job, where it has been generated.
RSpec.describe AUPSTestKit::CIBuildSuites do
  root_dir = File.expand_path('../..', __dir__)
  suite_generated = File.exist?(AUPSTestKit::CIBuildSuites::SUITE_FILE)
  suite_absent = 'the ci-build suite is not generated in this tree; it lives on the ci-build branch'
  suite_present = 'the ci-build suite is generated in this tree'

  # Boots the kit the way a deployment does and reports whether it lists the CI build suite.
  listed = lambda do |env|
    output, status = Open3.capture2e(env.merge('APP_ENV' => 'test'), 'bundle', 'exec', 'inferno', 'suites',
                                     chdir: root_dir)
    raise output unless status.success?

    output.include?('au_ps_ci_build')
  end

  it 'is enabled only when INFERNO_CI_BUILD_SUITES is exactly "true"' do
    expect(described_class.enabled?('INFERNO_CI_BUILD_SUITES' => 'true')).to be(true)
    %w[false TRUE 1 yes].each do |value|
      expect(described_class.enabled?('INFERNO_CI_BUILD_SUITES' => value)).to be(false)
    end
    expect(described_class.enabled?({})).to be(false)
  end

  it 'loads the suite only when the flag is set and the suite has been generated' do
    Dir.mktmpdir('au_ps_ci_build_suites_spec') do |dir|
      generated = File.join(dir, 'au_ps_ci_build.rb')
      File.write(generated, '')
      missing = File.join(dir, 'absent.rb')

      expect(described_class.load?({ 'INFERNO_CI_BUILD_SUITES' => 'true' }, suite_file: generated)).to be(true)
      expect(described_class.load?({ 'INFERNO_CI_BUILD_SUITES' => 'true' }, suite_file: missing)).to be(false)
      expect(described_class.load?({ 'INFERNO_CI_BUILD_SUITES' => 'false' }, suite_file: generated)).to be(false)
      expect(described_class.load?({}, suite_file: generated)).to be(false)
    end
  end

  it 'points at the suite file named in config.ci-build.json' do
    config = JSON.parse(File.read(File.join(root_dir, 'config.ci-build.json')))

    expect(described_class::SUITE_FILE).to eq(File.join(root_dir, config.dig('kit', 'suite_file')))
  end

  it 'leaves the CI build suite out of an app booted without the flag' do
    expect(listed.call('INFERNO_CI_BUILD_SUITES' => nil)).to be(false)
  end

  it 'boots cleanly with the flag set and lists no CI build suite where none is generated',
     skip: (suite_present if suite_generated) do
    expect(listed.call('INFERNO_CI_BUILD_SUITES' => 'true')).to be(false)
  end

  it 'lists the CI build suite with the flag set where it is generated', skip: (suite_absent unless suite_generated) do
    expect(listed.call('INFERNO_CI_BUILD_SUITES' => 'true')).to be(true)
  end
end
