# frozen_string_literal: true

require_relative 'au_ps_composition_author/ips_summary_composition_author_author_resource_type_is_valid'

require_relative 'au_ps_composition_author/ips_summary_composition_author_author_ms_elements'

require_relative 'au_ps_composition_author/ips_summary_composition_author_author_ms_subelements'

require_relative 'au_ps_composition_author/ips_summary_composition_author_author_ms_identifier_slices'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Author
  class IpsSummaryCompositionAuthor < Inferno::TestGroup
    title 'AU PS Composition Author'
    description 'Verify the referenced author is a correctly populated AU PS Practitioner, AU PS PractitionerRole, AU PS Patient, AU PS RelatedPerson, AU PS Organization profiles or Device resource.'
    id :ips_summary_composition_author

    run_as_group

    test from: :ips_summary_composition_author_author_resource_type_is_valid

    test from: :ips_summary_composition_author_author_ms_elements

    test from: :ips_summary_composition_author_author_ms_subelements

    test from: :ips_summary_composition_author_author_ms_identifier_slices
  end
end
