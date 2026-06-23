# frozen_string_literal: true

require_relative 'composition_decorator'
require_relative 'bundle_entry_decorator'

# A decorator for FHIR::Bundle to add convenience methods
class BundleDecorator < FHIR::Bundle
  def initialize(data)
    if data.is_a?(Hash)
      super
    else
      super(data.respond_to?(:source_hash) ? data.source_hash : data.to_hash)
    end
  end

  def composition_resource
    return nil if composition_entry.nil?

    CompositionDecorator.new(composition_entry.resource)
  end

  def composition_entry
    entry.find { |entr| entr.resource.resourceType == 'Composition' }
  end

  def resources_by_references(entry_references)
    entry_references.filter_map { |ref| resource_by_reference(ref) }.uniq
  end

  def resource_by_reference(entry_reference)
    entry = resolve_entry_reference(entry_reference)
    entry&.resource
  end

  private

  def resolve_entry_reference_as_reference(entry_reference)
    base_url = BundleEntryDecorator.new(composition_entry).full_url_base

    entry.find do |entr|
      next unless entr.fullUrl&.start_with?('http')

      if base_url
        entr.fullUrl == base_url + entry_reference
      else
        # Composition fullUrl is a URN so no base URL is derivable. Fall back to
        # suffix match: a relative {Type}/{id} reference can resolve to an absolute
        # fullUrl that ends with /{Type}/{id} (FHIR bundle reference rules).
        entr.fullUrl.end_with?("/#{entry_reference}")
      end
    end
  end

  def resolve_entry_reference(entry_reference)
    is_urn = entry_reference.start_with?('urn:')
    is_url = entry_reference.start_with?('http') || entry_reference.start_with?('https')
    is_reference = !is_urn && !is_url && entry_reference.split('/').length == 2

    if is_urn || is_url
      canonical = strip_history_suffix(entry_reference)
      return entry.find { |entr| entr.fullUrl == canonical }
    end

    return resolve_entry_reference_as_reference(entry_reference) if is_reference

    nil
  end

  def strip_history_suffix(url)
    url&.sub(%r{/_history/[^/]+$}, '')
  end
end
