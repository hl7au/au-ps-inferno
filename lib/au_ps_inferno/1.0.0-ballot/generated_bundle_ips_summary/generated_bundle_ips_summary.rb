# frozen_string_literal: true


require_relative 'bundle_validation'

require_relative 'bundle_must_support_elements'

require_relative 'composition_must_support_elements'

require_relative 'composition_mandatory_sections'

require_relative 'composition_recommended_sections'

require_relative 'composition_optional_sections'

require_relative 'composition_undefined_sections'


module AUPSTestKit
  # Automatically generated high order group for Generated Bundle (IPS $summary)
  class AUPSSuite100ballotGeneratedBundleIpsSummary < Inferno::TestGroup
    title 'Generated Bundle (IPS $summary)'
    description 'Validates an AU PS bundle generated via the IPS $summary operation for profile conformance, Must Support elements, and composition sections.'
    id :suite_100ballot_generated_bundle_ips_summary
    
    
    run_as_group
    

    
    group from: :suite_100ballot_generated_bundle_ips_summary_bundle_validation
    
    group from: :suite_100ballot_generated_bundle_ips_summary_bundle_must_support_elements
    
    group from: :suite_100ballot_generated_bundle_ips_summary_composition_must_support_elements
    
    group from: :suite_100ballot_generated_bundle_ips_summary_composition_mandatory_sections
    
    group from: :suite_100ballot_generated_bundle_ips_summary_composition_recommended_sections
    
    group from: :suite_100ballot_generated_bundle_ips_summary_composition_optional_sections
    
    group from: :suite_100ballot_generated_bundle_ips_summary_composition_undefined_sections
    
  end
end
