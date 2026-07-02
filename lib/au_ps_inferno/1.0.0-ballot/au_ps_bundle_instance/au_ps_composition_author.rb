# frozen_string_literal: true

require_relative 'au_ps_composition_author/suite_au_ps_bundle_instance_au_ps_composition_author_author_resource_type_is_valid'

require_relative 'au_ps_composition_author/suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_elements'

require_relative 'au_ps_composition_author/suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_subelements'

require_relative 'au_ps_composition_author/suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_identifier_slices'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Author
  class AUPSSuiteAuPsBundleInstanceAuPsCompositionAuthor100ballot < Inferno::TestGroup
    title 'AU PS Composition Author'
    description 'Verify the referenced author is a correctly populated AU PS Practitioner, AU PS PractitionerRole, AU PS Patient, AU PS RelatedPerson, AU PS Organization profiles or Device resource.'
    id :suite_au_ps_bundle_instance_au_ps_composition_author_100ballot

    run_as_group

    test from: :suite_au_ps_bundle_instance_au_ps_composition_author_author_resource_type_is_valid_100ballot

    test from: :suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_elements_100ballot

    test from: :suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_subelements_100ballot

    test from: :suite_au_ps_bundle_instance_au_ps_composition_author_author_ms_identifier_slices_100ballot
  end
end
