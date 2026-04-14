# frozen_string_literal: true

require_relative 'basic_test_author_resource'
require_relative 'basic_test_author_tests'

module AUPSTestKit
  # Composes Composition author Must Support helpers for BasicTest.
  module BasicTestAuthorModule
    include BasicTestAuthorResource
    include BasicTestAuthorTests
  end
end
