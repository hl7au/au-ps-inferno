require_relative 'constants'
require_relative 'bundle_decorator'

module AUPSTestKit
  class BasicTest < Inferno::Test
    include Constants
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

    def get_composition_sections_info(sections_array_codes)
      au_ps_bundle_resource = BundleDecorator.new(scratch[:ips_bundle_resource].to_hash)
      composition_resource = au_ps_bundle_resource.composition_resource
      sections_array_codes.each do |section_code|
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