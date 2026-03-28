# frozen_string_literal: true

require_relative 'bundle_decorator'

module AUPSTestKit
  # Resolves Composition.custodian reference from the scratch bundle.
  module BasicTestCustodianResource
    def custodian_resource
      return nil unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      return nil unless composition_resource.present?

      custodian_ref = first_composition_custodian_reference(composition_resource)
      return nil unless custodian_ref.present?

      ref_str = custodian_ref.respond_to?(:reference) ? custodian_ref.reference : custodian_ref['reference']
      return nil if ref_str.blank?

      bundle_resource.resource_by_reference(ref_str)
    end

    private

    def first_composition_custodian_reference(composition_resource)
      return nil unless composition_resource.respond_to?(:custodian) && composition_resource.custodian.present?

      composition_resource.custodian
    end
  end
end
