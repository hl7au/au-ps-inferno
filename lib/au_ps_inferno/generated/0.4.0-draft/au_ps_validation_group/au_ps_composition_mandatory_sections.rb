# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/composition_decorator'
require_relative '../../../utils/bundle_decorator'

SECTIONS = %w[11450-4 48765-2 10160-0].freeze

module AUPSTestKit
  class AUPSCompositionMandatorySection < Inferno::Test
    title 'Composition has must-support elements'
    description 'Checks that the Composition resource contains mandatory must-support elements (status, type, subject.reference, date, author, title, section.title, section.text) and provides information about optional must-support elements (text, identifier, attester, custodian, event).'
    id :au_ps_composition_mandatory_sections

    def show_message(message, state_value)
      if state_value
        info message
      else
        warning message
      end
    end

    def execute_statistics(json_data, json_path_expression, message_base, humanized_name)
      data_value = JsonPath.on(json_data, json_path_expression).first.present?
      show_message("#{message_base}: #{humanized_name}: #{data_value}", data_value)
    end

    def composition_mandatory_sections_info
      au_ps_bundle_resource = BundleDecorator.new(scratch[:ips_bundle_resource].to_hash)
      composition_resource = au_ps_bundle_resource.composition_resource
      SECTIONS.each do |section_code|
        section = composition_resource.section_by_code(section_code)
        info "SECTION: #{section.code.coding.first.display}"
        section_references = section.entry_references
        section_references.each do |ref|
          info au_ps_bundle_resource.resource_info_by_entry_full_url(ref)
        end
      end
    end

    run do
      composition_mandatory_sections_info
    end
  end
end
