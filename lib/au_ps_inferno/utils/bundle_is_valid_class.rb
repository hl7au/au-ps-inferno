# frozen_string_literal: true

require_relative 'basic_validate_bundle_test'

module AUPSTestKit
  # The Bundle loaded by this test group is valid against the AU PS Bundle profile
  class BundleIsValidClass < BasicValidateBundleTest
    id :bundle_is_valid_class_test

    run do
      omit_unless_bundle_in_scratch
      omit_if omit_au_ps_validation?, OMIT_AU_PS_MESSAGE
      validate_au_ps_bundle
    end
  end
end
