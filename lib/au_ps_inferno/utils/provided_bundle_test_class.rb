# frozen_string_literal: true

require_relative 'basic_test_class'

module AUPSTestKit
  # Loads a Bundle pasted as text into the group's scratch space
  class ProvidedBundleTestClass < BasicTest
    id :provided_bundle_test_class

    NO_PROVIDED_BUNDLE_MESSAGE = 'No Bundle resource was provided, so this test group is omitted.'

    def parse_bundle_resource
      FHIR.from_contents(bundle_resource)
    rescue StandardError
      nil
    end

    run do
      omit_if bundle_resource.blank?, NO_PROVIDED_BUNDLE_MESSAGE
      resource = parse_bundle_resource
      assert resource.present?, 'The provided text could not be parsed as a FHIR resource'
      assert resource.resourceType == 'Bundle',
             "The provided resource is a #{resource.resourceType}, expected a Bundle"
      save_bundle_to_scratch(resource)
    end
  end
end
