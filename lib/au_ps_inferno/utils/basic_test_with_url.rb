# frozen_string_literal: true

module AUPSTestKit
  # A base class for all tests with FHIR server URL to decrease code duplication
  class BasicTestWithURL < BasicTest
    id :basic_test_with_url
  end
end
