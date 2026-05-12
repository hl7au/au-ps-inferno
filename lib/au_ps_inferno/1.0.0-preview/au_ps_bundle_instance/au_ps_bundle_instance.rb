# frozen_string_literal: true


require_relative 'bundle_validation'

require_relative 'au_ps_bundle_must_support_conformance'

require_relative 'au_ps_composition_must_support_conformance'

require_relative 'au_ps_composition_mandatory_sections'

require_relative 'au_ps_composition_recommended_sections'

require_relative 'au_ps_composition_optional_sections'

require_relative 'au_ps_composition_undefined_sections'

require_relative 'au_ps_composition_subject'

require_relative 'au_ps_composition_author'

require_relative 'au_ps_composition_custodian'

require_relative 'au_ps_composition_attester'


module AUPSTestKit
  # Automatically generated high order group for AU PS Bundle Instance
  class AUPSSuite100previewAuPsBundleInstance < Inferno::TestGroup
    title 'AU PS Bundle Instance'
    description 'Validates a static AU PS bundle instance for profile conformance, Must Support elements, and composition sections.'
    id :suite_100preview_au_ps_bundle_instance
    
    
    run_as_group
    

    
    group from: :suite_100preview_au_ps_bundle_instance_bundle_validation
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_bundle_must_support_conformance
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_must_support_conformance
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_mandatory_sections
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_recommended_sections
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_optional_sections
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_undefined_sections
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_subject
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_author
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_custodian
    
    group from: :suite_100preview_au_ps_bundle_instance_au_ps_composition_attester
    
  end
end
