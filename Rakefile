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

namespace :generator do
  desc 'Generate AU PS/IPS test suites. Set ADDITIONAL_IG_RESOURCES to a folder to load extra JSON resources.'
  task :generate do
    require 'au_ps_inferno/generator/generator'
    extra = ENV['ADDITIONAL_IG_RESOURCES']
    if extra.nil? || extra.empty?
      default_extra = File.join(File.dirname(__FILE__), 'additional_resources')
      extra = default_extra if File.directory?(default_extra)
    end
    opts = extra ? { additional_resources_path: extra } : {}
    Generator.new('lib/au_ps_inferno/igs/0.5.0-preview.tgz', **opts).generate
  end
end
