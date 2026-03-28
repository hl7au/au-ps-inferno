# frozen_string_literal: true

require_relative '../bundle_decorator'

module AUPSTestKit
  # Resolves Composition.author reference from the scratch bundle.
  module BasicTestAuthorResource
    def author_resource
      return nil unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      return nil unless composition_resource.present?

      author_ref = first_composition_author_reference(composition_resource)
      return nil unless author_ref.present?

      ref_str = author_ref.respond_to?(:reference) ? author_ref.reference : author_ref['reference']
      return nil if ref_str.blank?

      bundle_resource.resource_by_reference(ref_str)
    end

    private

    def first_composition_author_reference(composition_resource)
      return nil unless composition_resource.respond_to?(:author) && composition_resource.author.present?

      composition_resource.author.first
    end
  end
end
