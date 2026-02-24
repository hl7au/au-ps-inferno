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
  desc 'Generate test suites for the AU PS and IPS implementation guides'
  task :generate do
    require 'au_ps_inferno/generator/generator'
    Generator.new('lib/au_ps_inferno/igs/0.5.0-preview.tgz').generate
  end
end
