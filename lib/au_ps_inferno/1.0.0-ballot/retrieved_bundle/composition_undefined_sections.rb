# frozen_string_literal: true



require_relative 'composition_undefined_sections/suite_100ballot_retrieved_bundle_composition_undefined_sections_sections_may_be_populated'


module AUPSTestKit
  # Automatically generated primitive group for Composition Undefined Sections
  class AUPSSuite100ballotRetrievedBundleCompositionUndefinedSections < Inferno::TestGroup
    title 'Composition Undefined Sections'
    description 'Verifies that sections not defined in the profile may be populated without violating conformance.'
    id :suite_100ballot_retrieved_bundle_composition_undefined_sections
    
    optional
    
    
    run_as_group
    

    
    test from: :suite_100ballot_retrieved_bundle_composition_undefined_sections_sections_may_be_populated
    
  end
end
