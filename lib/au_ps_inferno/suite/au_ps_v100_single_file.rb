# frozen_string_literal: true

require_relative '../version'
require_relative 'single_file_suite_builder'

module AUPSTestKit
  AUPSSuiteSingleFile = SingleFileSuiteBuilder.build(
    suite_id: :au_ps_v100,
    ig_version: AUPSTestKit::IG_VERSION,
    suite_title: "AU PS #{AUPSTestKit::IG_VERSION} Test Suite (single-file, metaprogrammed)",
    suite_description: 'Same structure and test logic as au_ps_v100, built by looping over a small ' \
                       'BUNDLE_SOURCES array and calling Inferno\'s `test`/`group` DSL, instead of by ' \
                       'requiring ~90 generated files. See docs/single-file-metaprogrammed-suite.md.',
    metadata_dir: File.expand_path('..', __dir__)
  )
end
