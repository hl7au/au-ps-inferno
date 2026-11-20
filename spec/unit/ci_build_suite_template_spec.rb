# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'

require_relative '../../lib/au_ps_inferno/generator/ci_build_suite_template'

# Runs on master too, where the generated CI build suite is absent, so a broken template is
# caught before the refresh writes it to the ci-build branch.
RSpec.describe AUPSTestKit::CIBuildSuiteTemplate do
  root_dir = File.expand_path('../..', __dir__)
  suite_definition = File.join(root_dir, 'lib/au_ps_inferno/suite/au_ps_suite_definition')

  # Boots the kit in a child process without the flag, so no generated CI build suite is loaded
  # whatever the tree holds, then loads the class the template generates and reports it.
  boot_script = lambda do |suite_file|
    <<~RUBY
      require 'json'
      require 'inferno/config/application'
      require 'inferno/utils/migration'
      Inferno::Utils::Migration.new.run
      require 'inferno'
      Inferno::Application.finalize!
      require #{suite_file.inspect}
      suite = AUPSTestKit::AUPSCIBuildSuite
      puts JSON.generate(
        id: suite.id,
        title: suite.title,
        description: suite.description,
        ig_version: suite::IG_VERSION,
        metadata_path: suite::SUITE_VERSION.metadata_path,
        igs: suite.fhir_validators[:default].first.igs
      )
    RUBY
  end

  it 'generates a loadable class with the fixed id, a title showing the version and the #current package' do
    suite = Dir.mktmpdir('au_ps_ci_build_suite_template') do |dir|
      # The generated class requires au_ps_suite_definition from its own directory.
      File.write(File.join(dir, 'au_ps_suite_definition.rb'), "require #{suite_definition.inspect}\n")
      suite_file = File.join(dir, 'au_ps_ci_build.rb')
      File.write(suite_file, described_class.source('9.8.7-ci-build'))

      output, status = Open3.capture2e({ 'APP_ENV' => 'test', 'INFERNO_CI_BUILD_SUITES' => nil },
                                       RbConfig.ruby, '-e', boot_script.call(suite_file), chdir: root_dir)
      raise "Loading the generated CI build suite failed:\n#{output}" unless status.success?

      JSON.parse(output.lines.last)
    end

    expect(suite).to include(
      'id' => 'au_ps_ci_build',
      'title' => 'AU PS 9.8.7-ci-build Test Suite (tracks the CI build)',
      'ig_version' => '9.8.7-ci-build',
      'metadata_path' => File.join(root_dir, 'lib/au_ps_inferno/generated/ci-build/metadata.yaml'),
      'igs' => ['hl7.fhir.au.ps#current']
    )
    expect(suite['description']).to include('sessions started before it may stop rendering')
  end

  it 'varies only IG_VERSION with the package version' do
    first = described_class.source('1.0.1-ci-build')
    second = described_class.source('1.1.0-ci-build')

    expect(first).to include("IG_VERSION = '1.0.1-ci-build'")
    expect(first.sub('1.0.1-ci-build', '1.1.0-ci-build')).to eq(second)
  end

  it 'refuses anything that is not a package version, so nothing else reaches the generated source' do
    ["1.0.0'; system('id'); '", '', nil, 'current'].each do |version|
      expect { described_class.source(version) }.to raise_error(ArgumentError, /Not an IG package version/)
    end
  end
end
