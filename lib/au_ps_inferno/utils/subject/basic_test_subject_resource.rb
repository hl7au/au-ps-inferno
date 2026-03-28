# frozen_string_literal: true

require_relative '../bundle_decorator'

module AUPSTestKit
  # Resolves Composition.subject (Patient) from the scratch bundle.
  module BasicTestSubjectResource
    def subject_resource
      return false unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      return false unless composition_resource.present?

      subject = composition_resource.subject
      return false unless subject.present?

      bundle_resource.resource_by_reference(subject.reference)
    end
  end
end
