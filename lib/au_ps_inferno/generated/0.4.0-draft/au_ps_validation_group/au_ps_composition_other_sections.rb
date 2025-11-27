# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  class AUPSCompositionOtherSection < BasicTest
    title TEXTS[:au_ps_composition_other_sections][:title]
    description TEXTS[:au_ps_composition_other_sections][:description]
    id :au_ps_composition_other_sections

    run do
      au_ps_bundle_resource = BundleDecorator.new(scratch[:ips_bundle_resource].to_hash)
      composition_resource = au_ps_bundle_resource.composition_resource
      other_section_codes = composition_resource.section_codes - ALL_SECTIONS
      if other_section_codes.empty?
        info 'No other sections found'
      else
        other_section_codes.each do |section_code|
          section = composition_resource.section_by_code(section_code)
          if section.nil?
            warning "Section #{section_code} not found in Composition resource"
            next
          end
          section_references = section.entry_references
          if section_references.empty?
            warning "Section #{section.code.coding.first.display}(#{section_code}) has no entries"
          else
            info "SECTION: #{section.code.coding.first.display}"
            section.entry_references.each do |ref|
              info au_ps_bundle_resource.resource_info_by_entry_full_url(ref)
            end
          end
        end
      end
    end
  end
end
