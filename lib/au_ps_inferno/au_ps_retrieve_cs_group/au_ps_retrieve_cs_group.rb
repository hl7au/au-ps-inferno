# frozen_string_literal: true

require_relative './au_ps_cs_is_valid_test'
require_relative './au_ps_cs_supports_ips_recommended_ops'
require_relative './au_ps_cs_supports_au_ps_profiles'
require_relative '../utils/constants'

module AUPSTestKit
  class AUPSRetrieveCSGroup < Inferno::TestGroup
    include Constants

    title TEXTS[:au_ps_retrieve_cs_group][:title]
    description TEXTS[:au_ps_retrieve_cs_group][:description]
    id :au_ps_retrieve_cs_group
    run_as_group

    test from: :au_ps_cs_is_valid
    test from: :au_ps_cs_supports_ips_recommended_ops
    test from: :au_ps_cs_supports_au_ps_profiles
  end
end
