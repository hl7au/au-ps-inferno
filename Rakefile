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
  desc 'Generate AU PS/IPS test suites for every IG package archive in lib/au_ps_inferno/igs/. ' \
       'Set ADDITIONAL_IG_RESOURCES to a folder to load extra JSON resources.'
  task :generate do
    archives = Dir.glob(File.join(File.dirname(__FILE__), 'lib', 'au_ps_inferno', 'igs', '*.tgz'))
    raise 'No IG package archives found in lib/au_ps_inferno/igs/' if archives.empty?

    archives.each do |archive|
      puts "== Generating suite for #{archive} =="

      script = <<~RUBY
        require 'au_ps_inferno/generator/generator'
        extra = ENV.fetch('ADDITIONAL_IG_RESOURCES', nil)
        if extra.nil? || extra.empty?
          default_extra = File.join(Dir.pwd, 'additional_resources')
          extra = default_extra if File.directory?(default_extra)
        end
        opts = extra ? { additional_resources_path: extra } : {}
        Generator.new(#{archive.inspect}, **opts).generate
      RUBY
      system('bundle', 'exec', 'ruby', '-Ilib', '-e', script, exception: true)
    end

    require 'au_ps_inferno/generator/latest_alias_generator'
    Generator::LatestAliasGenerator.generate
  end
end
