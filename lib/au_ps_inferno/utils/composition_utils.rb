# frozen_string_literal: true

require_relative 'bundle_decorator'
require_relative 'composition_utils/boolean_and_stats'
require 'dry/container/error'
require 'inferno_suite_generator/utils/kept_resources_repository'
require 'inferno_suite_generator/utils/fhirpath_lab_message_linker'

# Utilities for FHIR Composition resources
module CompositionUtils
  include CompositionUtilsBooleanAndStats

  NO_BUNDLE_OMIT_MESSAGE = 'No AU PS Bundle was loaded by this test group (its inputs were not provided or ' \
                           'the Bundle could not be acquired), so this test is omitted.'

  # Each top-level group keeps its Bundle under its own scratch key so that a
  # group can never validate a Bundle acquired by a different group.
  BUNDLE_SOURCE_GROUPS = {
    'retrieve_au_ps_bundle_validation_tests' => 'retrieve',
    'generate_au_ps_using_ips_summary_validation_tests' => 'summary',
    'au_ps_bundle_instance' => 'instance'
  }.freeze

  def bundle_scratch_key
    id_str = self.class.id.to_s
    _slug, source = BUNDLE_SOURCE_GROUPS.find { |slug, _| id_str.include?(slug) }
    source ? :"bundle_ips_resource_#{source}" : :bundle_ips_resource
  end

  def scratch_bundle
    scratch[bundle_scratch_key]
  end

  def save_bundle_to_scratch(bundle)
    scratch[bundle_scratch_key] = bundle
    InfernoSuiteGenerator::KeptResourcesRepository.new.save(session_id: test_session_id, resource: bundle)
    save_entry_resources_to_scratch(bundle)
  end

  def save_entry_resources_to_scratch(bundle)
    resources = (bundle.entry || []).filter_map(&:resource).select { |resource| resource.id.present? }
    InfernoSuiteGenerator::KeptResourcesRepository.new.save_all(session_id: test_session_id, resources: resources)
  end

  def omit_unless_bundle_in_scratch
    omit_if scratch_bundle.blank?, NO_BUNDLE_OMIT_MESSAGE
  end

  def composition_resource_from_scratch
    return nil if scratch_bundle.blank?

    BundleDecorator.new(scratch_bundle).composition_resource
  end

  def section_fhirpath_prefix(section)
    code = section_first_coding_code(section)
    return '' if code.blank?

    "section.where(code.coding.code='#{code}')."
  end

  def element_fhirpath_line(resource, prefix, element, status)
    return nil if resource.blank?

    resource_type = resource.resourceType
    resource_id = resource.id
    return nil if resource_type.blank? || resource_id.blank?

    expression = "#{prefix}#{element}"
    path_display = fhirpath_lab_link(resource_type, resource_id, expression) || expression

    "#{status}: #{resource_type}/#{resource_id}: #{path_display}"
  end

  def fhirpath_lab_link(resource_type, resource_id, expression)
    base_url = fhirpathlab_url_for_linking
    resource_base_url = resource_base_url_for_linking
    return nil if base_url.blank? || resource_base_url.blank? || test_session_id.blank?

    InfernoSuiteGenerator::FhirpathLabMessageLinker.link_for(
      { resource_type: resource_type, resource_id: resource_id, path: expression },
      base_url: base_url,
      resource_base_url: resource_base_url,
      session_id: test_session_id
    )
  end

  def fhirpathlab_url_for_linking
    self.class.suite::FHIRPATHLAB_URL
  rescue NameError, Dry::Container::Error
    nil
  end

  def resource_base_url_for_linking
    "#{Inferno::Application['base_url']}/custom/#{self.class.suite.id}/resources"
  rescue NameError, Dry::Container::Error
    nil
  end

  def section_first_coding_code(section)
    coding = section&.code&.coding
    coding&.first&.code
  end

  def group_section_output(section_info_array)
    section_entities = {}
    section_info_array.each do |section_info|
      if section_entities.keys.include?(section_info)
        section_entities[section_info] += 1
      else
        section_entities[section_info] = 1
      end
    end
    section_entities.keys.map { |section_entity| "#{section_entity} x#{section_entities[section_entity]}" }
  end
end
