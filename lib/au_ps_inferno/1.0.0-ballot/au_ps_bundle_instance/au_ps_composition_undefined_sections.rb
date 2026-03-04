# frozen_string_literal: true



require_relative 'au_ps_composition_undefined_sections/suite_100ballot_au_ps_bundle_instance_au_ps_composition_undefined_sections_sections_may_be_populated'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Undefined Sections
  class AUPSSuite100ballotAuPsBundleInstanceAuPsCompositionUndefinedSections < Inferno::TestGroup
    title 'AU PS Composition Undefined Sections'
    description 'Verify the undefined sections are correctly populated in the AU PS Composition resource.'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_composition_undefined_sections
    
    optional
    
    
    run_as_group
    

    
    test from: :suite_100ballot_au_ps_bundle_instance_au_ps_composition_undefined_sections_sections_may_be_populated
    
  end
end
