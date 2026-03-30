# frozen_string_literal: true

module AUPSTestKit
  # Saving and retrieving bundle entities from scratch.
  module BasicTestScratchBundleEntriesModule
    def save_bundle_entities_to_scratch(bundle)
      scratch[:bundle_entities] = bundle.entry.map do |entry|
        {
          full_url: entry.fullUrl,
          resource_type: entry.resource.resourceType,
          resource: entry.resource
        }
      end
    end

    def bundle_entities_from_scratch
      scratch[:bundle_entities] || []
    end

    def bundle_entity_from_scratch(full_url)
      bundle_entities_from_scratch.find { |entity| entity[:full_url] == full_url }
    end

    def bundle_entity_resource_from_scratch(full_url)
      return nil if bundle_entity_from_scratch(full_url).nil?

      bundle_entity_from_scratch(full_url)[:resource]
    end
  end
end
