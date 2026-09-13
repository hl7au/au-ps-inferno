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

namespace :dev_tools do
  desc 'Install or update the shared bin/hot-reload watcher script'
  task :install_hot_reload do
    require 'inferno_suite_generator/dev_tools/hot_reload_installer'

    installer = InfernoSuiteGenerator::DevTools::HotReloadInstaller.new
    result = installer.install!(force: ENV['FORCE'] == '1')

    case result
    when :installed
      puts "Installed bin/hot-reload (v#{installer.installed_version})."
      puts "Wire it into compose.yaml - see inferno_suite_generator's README 'Auto-reload' section."
    when :updated
      puts "Updated bin/hot-reload to v#{installer.installed_version}."
    when :up_to_date
      puts "bin/hot-reload is already up to date (v#{installer.installed_version})."
    end
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
