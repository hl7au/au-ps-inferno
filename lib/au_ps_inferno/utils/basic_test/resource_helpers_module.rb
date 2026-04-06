# frozen_string_literal: true

require 'yaml'

module AUPSTestKit
  # Cross-cutting helpers: metadata, resource typing, profiles, identifiers, coding.
  module BasicTestResourceHelpersModule
    private

    def calculate_message_level(failed: false, warning: false, info: false)
      return 'error' if failed
      return 'warning' if warning
      return 'info' if info

      'info'
    end

    def resource_type(resource)
      return nil unless resource.present?

      resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
    end

    def author_resource_type_and_profiles(resource)
      return ['', ''] unless resource.present?

      resource_type_str = resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
      profiles = resource_profiles(resource)
      profile_str = profiles.is_a?(Array) ? profiles.join(', ') : profiles.to_s
      [resource_type_str.to_s, profile_str.to_s]
    end

    def resource_profiles(resource)
      return [] unless resource.present?

      if resource.respond_to?(:meta)
        meta = resource.meta
        return meta.profile if meta&.profile.present?
      end
      if resource.is_a?(Hash)
        resource.dig('meta', 'profile') || []
      else
        []
      end
    end

    def ms_elements_populated_message(resource, list_lines)
      ref = prepare_resource_type_and_profile_str(resource, 'author')
      "#{ms_elements_populated_title}#{ref}#{populated_elements_list(list_lines)}"
    end

    def ms_elements_populated_title
      'Must Support elements correctly populated'
    end

    def prepare_resource_type_and_profile_str(resource, human_readable_name)
      resource_type_str = resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
      profiles = resource_profiles(resource)
      profile_str = profiles.is_a?(Array) && profiles.length.positive? ? profiles.join(', ') : nil

      result = [resource_type_str, profile_str].compact.join(' — ')

      "\n\n**Referenced #{human_readable_name}**: #{result}"
    end

    # Backward-compatible plain formatter used by legacy MS message helpers.
    def resource_type_and_profile_str(resource, _human_readable_name = nil)
      resource_type_str = resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
      profiles = resource_profiles(resource)
      profile_str = profiles.is_a?(Array) && profiles.length.positive? ? profiles.join(', ') : nil
      [resource_type_str, profile_str].compact.join(' — ')
    end

    def populated_elements_list(list_lines)
      return '' if list_lines.blank?

      "\n\n## List of Must Support elements (complex) populated or missing\n\n#{list_lines.join("\n\n")}"
    end

    def identifiers_from_resource(resource)
      return nil unless resource.present?

      if resource.respond_to?(:identifier)
        resource.identifier
      elsif resource.is_a?(Hash)
        resource['identifier']
      end
    end

    def identifier_system(ident)
      return nil unless ident.present?

      ident.respond_to?(:system) ? ident.system : ident['system']
    end

    def find_identifier_by_system(identifiers, system_url)
      return nil if identifiers.blank? || system_url.blank?

      identifiers.find { |ident| identifier_system(ident).to_s.strip == system_url.to_s.strip }
    end

    def identifier_type_display(ident)
      return '' unless ident.present?

      type_val = ident.respond_to?(:type) ? ident.type : ident['type']
      return '' if type_val.blank?

      coding_suffix_from_type_value(type_val)
    end

    def coding_suffix_from_type_value(type_val)
      if type_val.respond_to?(:coding)
        suffix = first_coding_type_suffix(type_val.coding, hash_style: false)
        return suffix if suffix
      end
      if type_val.is_a?(Hash)
        suffix = first_coding_type_suffix(type_val['coding'], hash_style: true)
        return suffix if suffix
      end

      ''
    end

    def first_coding_type_suffix(coding, hash_style:)
      return nil unless coding.present?

      first_entry = coding.first
      hash_style ? coding_display_suffix_hash(first_entry) : coding_display_suffix(first_entry)
    end

    def coding_display_suffix(coding)
      display = coding.respond_to?(:display) ? coding.display : coding['display']
      code = coding.respond_to?(:code) ? coding.code : coding['code']
      ", type: #{display.presence || code.presence || '—'}"
    end

    def coding_display_suffix_hash(coding)
      ", type: #{coding['display'].presence || coding['code'].presence || '—'}"
    end

    def author_and_device_resource?(container_type, resource)
      is_author_and_device = container_type == 'author' && resource_type(resource) == 'Device'
      omit_if is_author_and_device, 'Test is ommited because the author reference resolves to a Device resource'
    end

    def guard_populated_resource(container_type)
      resource_is_poluated = raw_resource_type_is_valid(container_type)
      skip_if !resource_is_poluated[:valid?], resource_is_poluated[:msg]
    end
  end
end
