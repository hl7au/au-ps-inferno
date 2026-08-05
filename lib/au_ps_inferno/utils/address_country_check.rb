# frozen_string_literal: true

require_relative 'metadata_manager'

module AUPSTestKit
  # Flags Address.country values that don't match the au-address fixed code "AU"
  module AddressCountryCheck
    AU_COUNTRY_CODE = 'AU'
    METADATA_PATH = File.expand_path('../metadata.yaml', __dir__)

    module_function

    def address_paths_by_resource_type
      @address_paths_by_resource_type ||=
        MetadataManager.new(METADATA_PATH).address_profile_elements.each_with_object({}) do |element, paths|
          (paths[element[:resource_type]] ||= []) << element[:path]
        end
    end

    def messages_for(resource)
      return [] unless resource.is_a?(FHIR::Bundle)

      resource.entry.flat_map { |entry| messages_for_entry(entry) }
    end

    def messages_for_entry(entry)
      candidate = entry&.resource
      paths = candidate && address_paths_by_resource_type[candidate.resourceType]
      return [] if paths.blank?

      paths.flat_map { |path| incorrect_country_messages(candidate, path) }
    end

    def incorrect_country_messages(resource, path)
      addresses_at_path(resource, path).filter_map do |address, indexed_path|
        country = address&.country
        next if country.blank? || country == AU_COUNTRY_CODE

        { type: 'warning', message: incorrect_country_message(resource, indexed_path, country) }
      end
    end

    def addresses_at_path(resource, path)
      path.split('.').inject([[resource, '']]) do |nodes, segment|
        nodes.flat_map do |node, prefix|
          next [] unless node.respond_to?(segment)

          Array(node.public_send(segment)).each_with_index.map do |child, idx|
            [child, prefix.empty? ? "#{segment}[#{idx}]" : "#{prefix}.#{segment}[#{idx}]"]
          end
        end
      end
    end

    def incorrect_country_message(resource, indexed_path, country)
      "#{resource.resourceType}/#{resource.id}: #{indexed_path}.country = \"#{country}\" does " \
        'not match the au-address fixed code "AU".'
    end
  end
end
