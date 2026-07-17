# frozen_string_literal: true

require_relative 'au_ps_cs_is_valid_test'

require_relative 'au_ps_cs_supports_ips_recommended_ops'

require_relative 'au_ps_cs_supports_au_ps_profiles'

require_relative '../../utils/common_inputs_module'

module AUPSTestKit
  # Tests for CapabilityStatement resource
  class AUPSRetrieveCSGroup100preview < Inferno::TestGroup
    title 'Retrieve Capability Statement'
    description 'Verifies that the server exposes a valid CapabilityStatement and declares support for AU PS profiles and IPS recommended operations.'
    id :au_ps_retrieve_cs_group_100preview

    CommonInputsModule.shared_inputs(self)

    run_as_group

    test from: :au_ps_cs_is_valid_100preview

    test from: :au_ps_cs_supports_ips_recommended_ops_100preview

    test from: :au_ps_cs_supports_au_ps_profiles_100preview
  end
end
