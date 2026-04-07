# frozen_string_literal: true

require_relative 'basic_test_attester_message_helpers'
require_relative 'basic_test_attester_resource'
require_relative 'basic_test_attester_identifier_slices'

module AUPSTestKit
  # Composes attester.party Must Support validation helpers for BasicTest.
  module BasicTestAttesterModule
    include BasicTestAttesterMessageHelpers
    include BasicTestAttesterResource
    include BasicTestAttesterIdentifierSlices
  end
end
