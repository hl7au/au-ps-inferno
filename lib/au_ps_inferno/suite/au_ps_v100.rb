# frozen_string_literal: true

require_relative 'au_ps_suite_definition'

module AUPSTestKit
  # Test suite for the AU PS (Australian Primary Care and Shared Health) Implementation Guide 1.0.0.
  class AUPSSuitePreview < Inferno::TestSuite
    IG_VERSION = '1.0.0'
    SUITE_VERSION = SuiteVersion.new(key: '1.0.0', ig_version: IG_VERSION)

    extend AUPSSuiteDefinition

    define_au_ps_suite(
      SUITE_VERSION,
      title: "AU PS #{IG_VERSION} Test Suite",
      description: 'Validates AU PS (Australian Primary Care and Shared Health) bundles, ' \
                   'compositions, sections, and server CapabilityStatement support for the ' \
                   "#{IG_VERSION} implementation guide."
    )
  end
end
