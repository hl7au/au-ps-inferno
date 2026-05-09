# frozen_string_literal: true

require_relative '../bundle_decorator'

module AUPSTestKit
  # Resolves Composition attester.party reference from the scratch bundle and loads attester metadata.
  module BasicTestAttesterResource
    def attester_party_resource
      return nil unless scratch_bundle.present?

      ref_str = attester_party_ref_from_bundle(BundleDecorator.new(scratch_bundle))
      return nil if ref_str.blank?

      bundle_entity_resource_from_scratch(ref_str)
    end

    private

    def attester_composition_attesters(composition_resource)
      composition_resource.respond_to?(:attester) ? composition_resource.attester : nil
    end

    def attester_party_for_attester(attester)
      attester.respond_to?(:party) ? attester.party : attester['party']
    end

    def find_first_attester_with_party(attesters)
      attesters.find { |a| attester_party_for_attester(a).present? }
    end

    def attester_party_reference_from_attester(attester_with_party)
      party_ref = attester_party_for_attester(attester_with_party)
      return nil if party_ref.blank?

      party_ref.respond_to?(:reference) ? party_ref.reference : party_ref['reference']
    end

    def attester_party_ref_from_bundle(bundle_resource)
      composition_resource = bundle_resource.composition_resource
      return nil unless composition_resource.present?

      attesters = attester_composition_attesters(composition_resource)
      return nil if attesters.blank?

      attester_with_party = find_first_attester_with_party(attesters)
      return nil unless attester_with_party.present?

      ref_str = attester_party_reference_from_attester(attester_with_party)
      return nil if ref_str.blank?

      ref_str
    end
  end
end
