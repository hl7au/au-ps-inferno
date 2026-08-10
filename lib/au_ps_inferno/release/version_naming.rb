# frozen_string_literal: true

module Release
  # Turns an IG package version string (e.g. "1.0.0", "1.1.0-ballot") into the
  # Ruby-safe identifiers used to build and require a generated suite.
  module VersionNaming
    module_function

    def reformatted(version)
      "v#{version.delete('.').tr('-', '_')}"
    end

    def suite_id(version)
      :"au_ps_release_#{reformatted(version)}"
    end

    def suite_constant_name(version)
      "AUPSSuiteRelease#{reformatted(version).upcase}"
    end

    def folder_name(version)
      version
    end
  end
end
