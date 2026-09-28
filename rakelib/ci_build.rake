# frozen_string_literal: true

require_relative 'ci_build' # rubocop:disable Lint/RequireRelativeSelfPath -- loads ci_build.rb, not this file

namespace :au_ps do
  namespace :ci_build do
    desc 'Report whether the AU PS CI build has changed since the ci-build suite was generated'
    task :check do
      ci_build = AUPSTestKit::CIBuild.new
      published = ci_build.published_manifest
      changed = published['date'] != ci_build.recorded_date
      puts "CI build #{published['version']} dated #{published['date']}; " \
           "ci-build suite generated from #{ci_build.recorded_date}: #{changed ? 'changed' : 'unchanged'}"
      AUPSTestKit::CIBuild.write_github_output(changed:)
    end

    desc 'Download the AU PS CI build package into lib/au_ps_inferno/igs/ci-build.tgz'
    task :download do
      AUPSTestKit::CIBuild.new.download
    end

    desc 'Regenerate the ci-build suite when the AU PS CI build has changed (pass "force" to always regenerate)'
    task :refresh, [:force] do |_task, args|
      ci_build = AUPSTestKit::CIBuild.new
      previous_version = ci_build.version
      previous_date = ci_build.recorded_date
      changed = ci_build.refresh(force: args[:force] == 'force') do
        Rake::Task['au_ps:generate'].invoke(AUPSTestKit::CIBuild::VERSION_KEY)
      end
      if changed
        puts "Regenerated the ci-build suite from #{ci_build.version} dated #{ci_build.recorded_date}"
      else
        puts "CI build unchanged since #{ci_build.recorded_date}; nothing to regenerate"
      end
      AUPSTestKit::CIBuild.write_github_output(changed:, version: ci_build.version, date: ci_build.recorded_date,
                                               previous_version:, previous_date:)
    end
  end
end
