# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/composition_decorator'
require_relative '../../../utils/bundle_decorator'
require_relative '../../../utils/basic_test_class'

SECTIONS = %w[11450-4 48765-2 10160-0].freeze

module AUPSTestKit
  class AUPSCompositionMandatorySection < BasicTest
    title 'Composition contains mandatory sections with entry references'
    description 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.'
    id :au_ps_composition_mandatory_sections

    def composition_mandatory_sections_info
      au_ps_bundle_resource = BundleDecorator.new(scratch[:ips_bundle_resource].to_hash)
      composition_resource = au_ps_bundle_resource.composition_resource
      SECTIONS.each do |section_code|
        section = composition_resource.section_by_code(section_code)
        info "SECTION: #{section.code.coding.first.display}"
          section.entry_references.each do |ref|
          info au_ps_bundle_resource.resource_info_by_entry_full_url(ref)
        end
      end
    end

    run do
      composition_mandatory_sections_info
    end
  end
end
