# frozen_string_literal: true

module AUPSTestKit
  # Suites that track the AU PS CI build are carried in the gem but loaded only where
  # INFERNO_CI_BUILD_SUITES=true, which the development deployment sets and production never
  # does.
  module CIBuildSuites
    ENV_FLAG = 'INFERNO_CI_BUILD_SUITES'

    # @param env [#fetch] the environment to read, ENV by default
    # @return [Boolean] true only when the flag is exactly "true"
    def self.enabled?(env = ENV)
      env.fetch(ENV_FLAG, 'false') == 'true'
    end
  end
end
