require_relative 'composition_decorator'

class BundleDecorator < FHIR::Bundle
  def initialize(bundle)
    super(bundle)
  end

  def composition_resource
    composition_resource_data = entry.find { |e| e.resource.resourceType == 'Composition' }.resource.to_hash
    CompositionDecorator.new(composition_resource_data)
  end

  def resource_info_by_entry_full_url(entry_full_url)
    resource = entry.find { |e| e.fullUrl == entry_full_url }.resource
    profiles = resource.meta&.profile || []
    profiles = profiles.length > 0 ? profiles.join(', ') : 'Without Profiles'

    "#{resource.resourceType} (#{profiles})"
  end
end