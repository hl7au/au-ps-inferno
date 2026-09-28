# frozen_string_literal: true

require_relative '../metadata_manager'

module AUPSTestKit
  # Resolves the metadata and IG version of the suite version a test runs in. Every suite
  # version passes them down through Inferno's +config+ options (see
  # {AUPSTestKit::SuiteVersion#runnable_options}), so one shared test class reads the
  # metadata generated for whichever suite includes it.
  module BasicTestSuiteVersionModule
    def metadata_manager
      @metadata_manager ||= CompositionMetadataManager.new(suite_version_option(:au_ps_metadata_path))
    end

    # @return [String] the IG package version of the suite this test runs in
    def au_ps_ig_version
      suite_version_option(:au_ps_ig_version)
    end

    private

    def suite_version_option(name)
      config.options.fetch(name) do
        raise KeyError, "#{self.class.id} has no #{name} option; it only runs inside an AU PS suite version"
      end
    end
  end
end
