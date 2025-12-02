# frozen_string_literal: true

# Decorator for FHIR::Bundle::Entry
class BundleEntryDecorator < FHIR::Bundle::Entry
  def initialize(data)
    if data.is_a?(Hash)
      super
    else
      super(data.to_hash)
    end
  end

  def full_url_base
    return nil if fullUrl.nil?
    return nil unless fullUrl.start_with?('http') || fullUrl.start_with?('https')

    fullUrl.split("#{resource.resourceType}/#{resource.id}").first
  end
end