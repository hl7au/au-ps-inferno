# frozen_string_literal: true

require_relative 'bundle_decorator'

# A class to keep helper methods for section tests
class SectionTestClass
  attr_reader :target_resources_hash, :target_resource_types, :is_multiprofile, :name, :code, :references, :data

  def initialize(section_config, bundle_resource)
    @section_config = section_config
    @code = section_config['code']
    @name = section_config['name']
    @bundle_resource = BundleDecorator.new(bundle_resource)
    @target_resources_hash = section_config['resources']
    @target_resource_types = extract_target_resource_types(@target_resources_hash)
    @is_multiprofile = check_multiprofile?(@target_resource_types)
    @data = section_data
    @references = @data.present? ? @data.entry_references : []
  end

  def humanized_name
    "#{@name} (#{@code})"
  end

  def get_resource_by_reference(reference)
    @bundle_resource.resource_by_reference(reference)
  end

  def resource_type_is_expected?(resource_type)
    @target_resource_types.uniq.include?(resource_type)
  end

  def section_data
    composition_r = @bundle_resource.composition_resource
    if composition_r.present?
      target_section = composition_r.section_by_code(@code)
      return target_section if target_section.present?
    end
    nil
  end

  def find_requirements(resource_type_key)
    resource_type_info = @target_resources_hash[resource_type_key]
    resource_type_info.key?('requirements') ? resource_type_info['requirements'] : []
  end

  private

  def extract_target_resource_types(target_resources_hash)
    target_resources_hash.keys.map do |resource_type_key|
      resource_type_key.to_s.split('|').first
    end
  end

  def check_multiprofile?(target_resource_types)
    target_resource_types.uniq.select do |resource_type|
      target_resource_types.count(resource_type) > 1
    end.length.positive?
  end
end
