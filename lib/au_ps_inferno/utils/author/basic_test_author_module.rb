# frozen_string_literal: true

require_relative 'basic_test_author_resource'
require_relative 'basic_test_author_metadata'
require_relative 'basic_test_author_ms_elements_and_slices'
require_relative 'basic_test_author_ms_subelements_validation'
require_relative 'basic_test_author_tests'

module AUPSTestKit
  # Composes Composition author Must Support helpers for BasicTest.
  module BasicTestAuthorModule
    include BasicTestAuthorResource
    include BasicTestAuthorMetadata
    include BasicTestAuthorMsElementsAndSlices
    include BasicTestAuthorMsSubelementsValidation
    include BasicTestAuthorTests
  end
end
