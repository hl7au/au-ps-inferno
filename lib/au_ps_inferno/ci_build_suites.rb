# frozen_string_literal: true

module AUPSTestKit
  # The suite that tracks the AU PS CI build is loaded only where INFERNO_CI_BUILD_SUITES=true,
  # which the ci-build environment sets and production never does. The suite itself lives only
  # on the ci-build branch, which the Refresh CI Build Suite workflow maintains; master and gems
  # built from it carry the tooling but not the suite, so the flag alone is not enough to load it.
  module CIBuildSuites
    ENV_FLAG = 'INFERNO_CI_BUILD_SUITES'
    SUITE_FILE = File.expand_path('suite/au_ps_ci_build.rb', __dir__)

    # @param env [#fetch] the environment to read, ENV by default
    # @return [Boolean] true only when the flag is exactly "true"
    def self.enabled?(env = ENV)
      env.fetch(ENV_FLAG, 'false') == 'true'
    end

    # @param env [#fetch] the environment to read, ENV by default
    # @param suite_file [String] the generated suite class
    # @return [Boolean] true only when the flag is exactly "true" and the suite has been generated
    def self.load?(env = ENV, suite_file: SUITE_FILE)
      enabled?(env) && File.exist?(suite_file)
    end
  end
end
