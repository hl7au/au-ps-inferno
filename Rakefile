# frozen_string_literal: true

require 'inferno_ps_suite_generator'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError # rubocop:disable Lint/SuppressedException
end

namespace :db do
  desc 'Apply changes to the database'
  task :migrate do
    require 'inferno/config/application'
    require 'inferno/utils/migration'
    Inferno::Utils::Migration.new.run
  end
end

namespace :au_ps do
  desc 'Generate tests'
  task :generate do
    InfernoPsSuiteGenerator::Generator.generate(
      {
        title: 'AU PS',
        ig_identifier: 'hl7.fhir.au.ps',
        gem_name: 'au_ps_inferno',
        core_file_path: './lib/au_ps_inferno.rb',
        output_path: './lib/au_ps_inferno',
        test_module_name: 'AUPS',
        test_id_prefix: 'au_ps',
        test_kit_module_name: 'AUPSTestKit',
        test_suite_class_name: 'AUPSInferno',
        base_output_file_name: 'au_ps_inferno.rb',
        version: '0.1.0-ci-build',
        igs: 'hl7.fhir.uv.ips#1.1.0'
      }
    )
  end
end
