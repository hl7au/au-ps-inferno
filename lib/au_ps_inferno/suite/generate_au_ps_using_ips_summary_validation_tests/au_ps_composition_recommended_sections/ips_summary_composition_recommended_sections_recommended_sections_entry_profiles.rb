# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition Recommended Sections capable of populating referenced profiles
  class IpsSummaryCompositionRecommendedSectionsCompositionRecommendedSectionsCapableOfPopulatingReferencedProfiles < BasicTest
    title 'AU PS Composition Recommended Sections capable of populating referenced profiles'
    description 'Recommended section SHALL be capable of populating section.entry with the referenced profiles and SHOULD correctly populate section.entry if a value is known.'
    id :ips_summary_composition_recommended_sections_recommended_sections_entry_profiles

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end

    run do
      test_composition_recommended_sections
    end
  end
end
