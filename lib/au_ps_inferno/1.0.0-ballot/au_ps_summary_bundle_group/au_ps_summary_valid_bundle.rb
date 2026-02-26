# frozen_string_literal: true

require_relative '../../utils/summary_valid_bundle_class'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class AUPSSummaryValidBundle100ballot < SummaryValidBundleClass
    title 'Server generates AU Patient Summary using IPS $summary operation'
    description 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle'
    id :au_ps_summary_valid_bundle_100ballot

    
  end
end
