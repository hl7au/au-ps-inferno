# frozen_string_literal: true

module AUPSTestKit
  # Shared accessor for the Composition resource held in scratch.
  module BasicTestCompositionSubelementsModule
    private

    def composition_resource_from_scratch
      return nil unless scratch_bundle.present?

      BundleDecorator.new(scratch_bundle).composition_resource
    end
  end
end
