# frozen_string_literal: true

require_relative '../../utils/basic_test_class'

module AUPSTestKit
  # The Must Support elements populated in the Composition resource.
  class AUPSRetrieveBundleCompositionMUSTSUPPORTElements100ballot < BasicTest
    title 'Composition has must-support elements'
    description 'Checks that the Composition resource contains mandatory must-support elements (status, type, subject.reference, date, author, title, section.title, section.text) and provides information about optional must-support elements (text, identifier, attester, custodian, event).'
    id :au_ps_retrieve_bundle_composition_must_support_elements_100ballot

    
    run do
      composition_mandatory_ms_elements_info([{:expression=>"attester", :label=>"attester"}, {:expression=>"attester.party", :label=>"attester.party"}, {:expression=>"attester.time", :label=>"attester.time"}, {:expression=>"custodian", :label=>"custodian"}, {:expression=>"event", :label=>"event"}, {:expression=>"event.period", :label=>"event.period"}, {:expression=>"identifier", :label=>"identifier"}, {:expression=>"section", :label=>"section"}, {:expression=>"section.emptyReason", :label=>"section.emptyReason"}, {:expression=>"section.entry", :label=>"section.entry"}], [{:expression=>"attester.mode", :label=>"attester.mode"}, {:expression=>"author", :label=>"author"}, {:expression=>"date", :label=>"date"}, {:expression=>"event.code", :label=>"event.code"}, {:expression=>"section", :label=>"section"}, {:expression=>"section.code", :label=>"section.code"}, {:expression=>"section.text", :label=>"section.text"}, {:expression=>"section.title", :label=>"section.title"}, {:expression=>"status", :label=>"status"}, {:expression=>"subject", :label=>"subject"}, {:expression=>"title", :label=>"title"}, {:expression=>"type", :label=>"type"}])
    end
    
  end
end
