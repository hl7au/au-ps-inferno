# frozen_string_literal: true

require_relative './au_ps_cs_is_valid_test'
require_relative './au_ps_cs_supports_ips_recommended_ops'
require_relative './au_ps_cs_supports_au_ps_profiles'
require_relative '../utils/constants'

module AUPSTestKit
  # Tests for CapabilityStatement resource
  class AUPSRetrieveCSGroup < Inferno::TestGroup
    extend Constants

    title t_title(:au_ps_retrieve_cs_group)
    description t_description(:au_ps_retrieve_cs_group)
    id :au_ps_retrieve_cs_group
    run_as_group

    test from: :au_ps_cs_is_valid
    test from: :au_ps_cs_supports_ips_recommended_ops
    test from: :au_ps_cs_supports_au_ps_profiles
  end
end
