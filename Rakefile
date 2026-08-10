# frozen_string_literal: true

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

namespace :deps do
  desc 'Get dependencies for the test suites'
  task :get do
    require_relative 'scripts/fetch_structure_definitions'
    fetch_structure_definitions('additional_resources/deps_urls.txt', 'additional_resources')
  end
end

namespace :generator do
  desc 'Generate AU PS/IPS test suites. Set ADDITIONAL_IG_RESOURCES to a folder to load extra JSON resources.'
  task :generate do
    require 'au_ps_inferno/generator/generator'
    extra = ENV.fetch('ADDITIONAL_IG_RESOURCES', nil)
    if extra.nil? || extra.empty?
      default_extra = File.join(File.dirname(__FILE__), 'additional_resources')
      extra = default_extra if File.directory?(default_extra)
    end
    opts = extra ? { additional_resources_path: extra } : {}
    Generator.new(**opts).generate
  end
end

namespace :release do
  desc 'Download every published hl7.fhir.au.ps package version into lib/au_ps_inferno/igs'
  task :fetch_igs do
    require 'au_ps_inferno/release/package_source'
    Release::PackageSource.new.sync_all
  end

  desc 'Fetch every IG package version (if needed) and generate its suite folder'
  task :generate do
    require 'au_ps_inferno/release/pipeline'
    Release::Pipeline.new.generate_all
  end

  desc 'Rewrite the generated-requires block in lib/au_ps_inferno.rb'
  task :attach do
    require 'au_ps_inferno/release/main_file_writer'
    Release::MainFileWriter.new.write!
  end

  desc 'Full release pipeline: fetch every IG version, generate its suite, attach it to lib/au_ps_inferno.rb'
  task new: %i[generate attach]
end
