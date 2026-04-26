# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/must_support_test'

# Wrapper to provide the utils from the MustSupportTest module.
class MSChecker
  include InfernoSuiteGenerator::MustSupportTest

  def exclude_uscdi_only_test?
    false
  end
end
