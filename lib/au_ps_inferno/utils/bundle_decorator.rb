# frozen_string_literal: true

require_relative 'composition_decorator'

# A decorator for FHIR::Bundle to add convenience methods
class BundleDecorator < FHIR::Bundle
  def composition_resource
    composition_resource_data = entry.find { |entr| entr.resource.resourceType == 'Composition' }.resource.to_hash
    CompositionDecorator.new(composition_resource_data)
  end

  def resource_info_by_entry_full_url(entry_full_url)
    entry_by_full_url = entry.find { |entr| entr.fullUrl == entry_full_url }
    return "Entry with fullUrl #{entry_full_url} not found in Bundle" if entry_by_full_url.nil?

    resource = entry_by_full_url.resource
    profiles = (resource.meta&.profile || []).sort
    profiles = profiles.length.positive? ? profiles.join(', ') : 'Without Profiles'

    "#{resource.resourceType} (#{profiles})"
  end
end
