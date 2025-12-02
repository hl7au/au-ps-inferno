# frozen_string_literal: true

require_relative 'composition_decorator'

# A decorator for FHIR::Bundle to add convenience methods
class BundleDecorator < FHIR::Bundle
  def initialize(data)
    if data.is_a?(Hash)
      super
    else
      super(data.to_hash)
    end
  end

  def composition_resource
    composition_resource_data = entry.find { |entr| entr.resource.resourceType == 'Composition' }.resource.to_hash
    CompositionDecorator.new(composition_resource_data)
  end

  def composition_entry
    entry.find { |entr| entr.resource.resourceType == 'Composition' }
  end

  def resource_info_by_entry_full_url(entry_full_url)
    entry_by_full_url = resolve_entry_reference(entry_full_url)
    return "Entry with fullUrl #{entry_full_url} not found in Bundle" if entry_by_full_url.nil?

    resource = entry_by_full_url.resource
    profiles = (resource.meta&.profile || []).sort
    profiles = profiles.length.positive? ? profiles.join(', ') : 'Without Profiles'

    "#{resource.resourceType} (#{profiles})"
  end

  private

  def resolve_entry_reference_as_reference(entry_reference)
    entry.find do |entr|
      entry_full_url = entr.fullUrl
      next unless entry_full_url.start_with?('http') || entry_full_url.start_with?('https')

      url_without_params = entry_full_url.split('?').first
      base_url = url_without_params.split(entry_reference).first

      entr.fullUrl == base_url + entry_reference
    end
  end

  def resolve_entry_reference(entry_reference)
    is_urn = entry_reference.start_with?('urn:')
    is_url = entry_reference.start_with?('http') || entry_reference.start_with?('https')
    is_reference = entry_reference.split('/').length == 2

    return entry.find { |entr| entr.fullUrl == entry_reference } if is_urn || is_url

    return resolve_entry_reference_as_reference(entry_reference) if is_reference

    nil
  end
end
