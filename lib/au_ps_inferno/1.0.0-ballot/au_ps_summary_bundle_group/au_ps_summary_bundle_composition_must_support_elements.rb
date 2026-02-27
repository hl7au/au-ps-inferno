# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # Verify the Must Support elements are correctly populated in the AU PS Composition resource.
  class AUPSSummaryBundleCompositionMUSTSUPPORTElements100ballot < BasicTest
    title 'AU PS Composition Must Support Elements (Must Have)'
    description 'Verify the Must Support elements are correctly populated in the AU PS Composition resource.'
    id :au_ps_summary_bundle_composition_must_support_elements_100ballot

    
    run do
      composition_mandatory_ms_elements_info([{:expression=>"attester", :label=>"attester"}, {:expression=>"custodian", :label=>"custodian"}, {:expression=>"event", :label=>"event"}, {:expression=>"identifier", :label=>"identifier"}, {:expression=>"section", :label=>"section"}], [{:expression=>"author", :label=>"author"}, {:expression=>"date", :label=>"date"}, {:expression=>"section", :label=>"section"}, {:expression=>"status", :label=>"status"}, {:expression=>"subject", :label=>"subject"}, {:expression=>"title", :label=>"title"}, {:expression=>"type", :label=>"type"}], [{:expression=>"attester.party", :label=>"attester.party"}, {:expression=>"attester.time", :label=>"attester.time"}, {:expression=>"event.period", :label=>"event.period"}, {:expression=>"section.emptyReason", :label=>"section.emptyReason"}, {:expression=>"section.entry", :label=>"section.entry"}], [{:expression=>"attester.mode", :label=>"attester.mode"}, {:expression=>"event.code", :label=>"event.code"}, {:expression=>"section.code", :label=>"section.code"}, {:expression=>"section.text", :label=>"section.text"}, {:expression=>"section.title", :label=>"section.title"}])
    end
    
  end
end
