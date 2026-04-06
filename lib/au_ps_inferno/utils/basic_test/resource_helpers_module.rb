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

    def load_metadata_yaml
      path = File.expand_path('../../1.0.0-ballot/metadata.yaml', __dir__)
      return nil unless File.file?(path)

      YAML.safe_load_file(path, permitted_classes: [Symbol], aliases: true)
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

      if resource.respond_to?(:meta) && resource.meta&.profile.present?
        resource.meta.profile
      elsif resource.is_a?(Hash)
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

    def get_extension_value_by_url(resouce, url)
      result = resouce&.extension&.find { |ext| ext.url == url }

      result.value if result.present?
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
      return coding_display_suffix(type_val.coding.first) if type_val.respond_to?(:coding) && type_val.coding.present?
      return coding_display_suffix_hash(type_val['coding'].first) if type_val.is_a?(Hash) && type_val['coding'].present?

      ''
    end

    def coding_display_suffix(coding)
      display = coding.respond_to?(:display) ? coding.display : coding['display']
      code = coding.respond_to?(:code) ? coding.code : coding['code']
      ", type: #{display.presence || code.presence || '—'}"
    end

    def coding_display_suffix_hash(coding)
      ", type: #{coding['display'].presence || coding['code'].presence || '—'}"
    end
  end
end
