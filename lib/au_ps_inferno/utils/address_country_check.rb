# frozen_string_literal: true

require 'fhirpath'

require_relative 'metadata_manager'

module AUPSTestKit
  # Flags Address.country values that don't match the au-address fixed code "AU"
  module AddressCountryCheck
    AU_COUNTRY_CODE = 'AU'

    module_function

    # @param metadata_path [String] the suite version's metadata.yaml; each version reads the
    #   Address element paths generated from its own IG package
    def address_paths_by_resource_type(metadata_path)
      @address_paths_by_resource_type ||= {}
      @address_paths_by_resource_type[metadata_path] ||=
        CompositionMetadataManager.new(metadata_path).address_profile_elements.each_with_object({}) do |element, paths|
          (paths[element[:resource_type]] ||= []) << element[:path]
        end
    end

    def messages_for(resource, metadata_path:)
      return [] unless resource.is_a?(FHIR::Bundle)

      address_paths = address_paths_by_resource_type(metadata_path)
      resource.entry.flat_map { |entry| messages_for_entry(entry, address_paths) }
    end

    def messages_for_entry(entry, address_paths)
      candidate = entry&.resource
      paths = candidate && address_paths[candidate.resourceType]
      return [] if paths.blank?

      paths.flat_map { |path| incorrect_country_messages(candidate, path) }
    end

    def incorrect_country_messages(resource, path)
      non_au_addresses(resource, path).each_with_index.map do |address, index|
        { type: 'warning', message: incorrect_country_message(resource, path, index, address.country) }
      end
    end

    def non_au_addresses(resource, path)
      compiled_non_au_query(resource.resourceType, path).call(resource)
    end

    def compiled_non_au_query(resource_type, path)
      @compiled_non_au_queries ||= {}
      @compiled_non_au_queries[[resource_type, path]] ||=
        Fhirpath.compile_as_array("#{path}.where(country.exists() and country != '#{AU_COUNTRY_CODE}')",
                                  FHIR.const_get(resource_type), FHIR::Address)
    end

    def incorrect_country_message(resource, path, index, country)
      "#{resource.resourceType}/#{resource.id}: #{path}[#{index}].country = \"#{country}\" does " \
        'not match the au-address fixed code "AU".'
    end
  end
end
