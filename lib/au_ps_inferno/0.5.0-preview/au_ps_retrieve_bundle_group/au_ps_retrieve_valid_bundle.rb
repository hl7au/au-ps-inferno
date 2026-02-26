# frozen_string_literal: true

require_relative '../../utils/retrieve_bundle_test_class'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class AUPSRetrieveValidBundle050preview < RetrieveBundleTestClass
    id :au_ps_retrieve_valid_bundle_050preview
    title 'Server provides valid requested AU PS Bundle'
    description 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and ' \
                'verify response is valid AU PS Bundle'
  end
end
