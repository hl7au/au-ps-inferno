# frozen_string_literal: true

require_relative 'bundle_validation/bundle_retrieval_bundle_validation_bundle_valid'

require_relative 'bundle_validation/bundle_retrieval_bundle_validation_bundle_valid_ips'

module AUPSTestKit
  # Automatically generated primitive group for Bundle Validation
  class BundleRetrievalBundleValidation < Inferno::TestGroup
    title 'Bundle Validation'
    description 'Validates that the bundle conforms to the Bundle profiles.'
    id :bundle_retrieval_bundle_validation

    run_as_group

    test from: :bundle_retrieval_bundle_validation_bundle_valid

    test from: :bundle_retrieval_bundle_validation_bundle_valid_ips
  end
end
