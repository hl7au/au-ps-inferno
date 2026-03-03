# frozen_string_literal: true


require_relative 'bundle_validation'

require_relative 'bundle_has_must_support_elements'

require_relative 'composition_must_support_elements'

require_relative 'composition_mandatory_sections'

require_relative 'composition_recommended_sections'

require_relative 'composition_optional_sections'

require_relative 'composition_undefined_sections'


module AUPSTestKit
  # Automatically generated high order group for AU PS Bundle Instance
  class AUPSSuite100ballotAuPsBundleInstance < Inferno::TestGroup
    title 'AU PS Bundle Instance'
    description 'Displays information about AU PS Bundle Instance in the Composition resource.'
    id :suite_100ballot_au_ps_bundle_instance

    
    group from: :suite_100ballot_au_ps_bundle_instance_bundle_validation
    
    group from: :suite_100ballot_au_ps_bundle_instance_bundle_has_must_support_elements
    
    group from: :suite_100ballot_au_ps_bundle_instance_composition_must_support_elements
    
    group from: :suite_100ballot_au_ps_bundle_instance_composition_mandatory_sections
    
    group from: :suite_100ballot_au_ps_bundle_instance_composition_recommended_sections
    
    group from: :suite_100ballot_au_ps_bundle_instance_composition_optional_sections
    
    group from: :suite_100ballot_au_ps_bundle_instance_composition_undefined_sections
    
  end
end
