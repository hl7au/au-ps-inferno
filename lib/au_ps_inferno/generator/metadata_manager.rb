# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require_relative 'constants'
require_relative '../../au_ps_inferno/utils/structure_definition_decorator'

class Generator
  # Builds and persists metadata for Composition sections from IG resources.
  #
  # Extracts Composition StructureDefinition sections and their entry constraints
  # (profiles, cardinality, mustSupport, section codes) and serializes them to YAML.
  # Output hash keys: +composition_sections+, +composition_mandatory_ms_elements+,
  # +composition_optional_ms_elements+, +profiles+.
  #
  # @see Generator::IGResourcesExtractor for loading IG resources
  # rubocop:disable Metrics/ClassLength
  class MetadataManager
    # @return [Array<Hash>] Array of section metadata hashes
    attr_reader :composition_sections

    include Constants

    REQUIRED_SECTIONS_CODES = %w[11450-4 48765-2 10160-0].freeze
    RECOMMENDED_SECTIONS_CODES = %w[11369-6 30954-2 47519-4 46264-8].freeze
    OPTIONAL_SECTIONS_CODES = %w[42348-3 104605-1 47420-5 11348-0 10162-6 81338-6 18776-5 29762-2 8716-3].freeze
    ALL_SECTIONS_CODES = REQUIRED_SECTIONS_CODES + RECOMMENDED_SECTIONS_CODES + OPTIONAL_SECTIONS_CODES.freeze
    SUB_ELEMENTS_TO_SKIP = %w[event.period event.code section.emptyReason section.entry section.code section.text
                              section.title meta.profile].freeze

    ATTESTER_PROFILE_REFS = [
      'Patient|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient',
      'RelatedPerson|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson',
      'Practitioner|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner',
      'PractitionerRole|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole',
      'Organization|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization'
    ].freeze

    AUTHOR_PROFILE_REFS = [
      'Practitioner|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner',
      'PractitionerRole|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole',
      'Patient|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient',
      'RelatedPerson|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson',
      'Organization|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization',
      'Device|http://hl7.org/fhir/uv/ips/StructureDefinition/Device-uv-ips'
    ].freeze

    CUSTODIAN_PROFILE_REFS = [
      'Organization|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization'
    ].freeze

    SUBJECT_PROFILE_REFS = [
      'Patient|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient'
    ].freeze

    # Initializes a MetadataManager for the given IG resources.
    #
    # @param ig_resources [Array<FHIR::Model>] Parsed IG resources (e.g. from IGResourcesExtractor#ig_resources)
    def initialize(ig_resources)
      @ig_resources = ig_resources
      reset_composition_metadata_ivars!
    end

    def reset_composition_metadata_ivars!
      @composition_sections = []
      @composition_mandatory_ms_elements = []
      @composition_mandatory_ms_sub_elements = []
      @composition_optional_ms_elements = []
      @composition_optional_ms_sub_elements = []
      @composition_mandatory_ms_slices = []
      @composition_optional_ms_slices = []
      @profiles = []
      @resources_filters = {}
      @normalized_sections_data = []
    end

    # Generates composition section metadata from IG resources (in-memory only).
    # Populates the internal composition sections and related metadata used by {#save_to_file}.
    #
    # @return [void]
    def initiate_build
      generate_metadata_for_composition
      extract_required_ms_elements
      extract_optional_ms_elements
      extract_profiles
      extract_resource_filters
      normalize_sections_data
    end

    def return_normalized_sections_data
      @normalized_sections_data
    end

    def normalize_sections_data
      @normalized_sections_data = @composition_sections.map do |section|
        normalize_section_data(section[:id])
      end
    end

    def extract_resource_filters
      @resources_filters = RESOURCES_FILTERS_MAPPING.map do |resource_profile, filters|
        {
          resource_profile: resource_profile,
          filters: filters
        }
      end
    end

    # Builds composition metadata and writes it to a YAML file.
    # Calls {#initiate_build} first, then serializes
    # {composition_sections:, composition_mandatory_ms_elements:, composition_optional_ms_elements:, profiles:}
    # to YAML.
    #
    # @param file_path [String] Path to the output YAML file (e.g. +metadata.yaml+)
    # @return [void]
    def save_to_file(file_path)
      initiate_build
      FileUtils.mkdir_p(File.dirname(file_path))
      File.write(file_path, YAML.dump(metadata_to_dump))
    end

    def metadata_to_dump
      metadata_dump_sections.merge(metadata_dump_ms_elements).merge(metadata_dump_tail)
    end

    def metadata_dump_sections
      {
        composition_sections: @composition_sections,
        subject: build_metadata_for_subject,
        author: build_metadata_for_author,
        custodian: build_metadata_for_custodian,
        attester: build_metadata_for_attester
      }
    end

    def metadata_dump_ms_elements
      {
        composition_mandatory_ms_elements: @composition_mandatory_ms_elements,
        composition_mandatory_ms_sub_elements: @composition_mandatory_ms_sub_elements,
        composition_optional_ms_elements: @composition_optional_ms_elements,
        composition_optional_ms_sub_elements: @composition_optional_ms_sub_elements,
        composition_mandatory_ms_slices: @composition_mandatory_ms_slices,
        composition_optional_ms_slices: @composition_optional_ms_slices
      }
    end

    def metadata_dump_tail
      {
        profiles: @profiles,
        resources_filters: @resources_filters,
        normalized_sections_data: @normalized_sections_data
      }
    end

    attr_reader :normalized_sections_data, :composition_mandatory_ms_elements, :composition_optional_ms_elements,
                :composition_mandatory_ms_sub_elements, :composition_optional_ms_sub_elements

    def normalize_section_data(section_id)
      section_data = @composition_sections.find { |section| section[:id] == section_id }
      return section_data if section_data.nil?

      {
        'code' => section_data[:code],
        'display' => section_data[:short],
        'resources' => build_section_resources(section_data)
      }
    end

    def normalize_slice_data(slice)
      {
        path: slice[:path],
        label: "#{slice[:path]} (#{slice[:sliceName]})"
      }
    end

    def optional_ms_slices
      @composition_optional_ms_slices.map do |slice|
        normalize_slice_data(slice)
      end
    end

    def all_sections_data_codes
      ALL_SECTIONS_CODES
    end

    def composition_ms_sections_elements
      filtered = composition_extract_ms_elements_without_slices.filter do |element|
        element&.path&.include?('Composition.section.')
      end
      filtered.map { |element| section_element_expression_min(element) }.uniq
    end

    def section_element_expression_min(element)
      path = element.path.gsub('Composition.section.', '')
      { expression: path, min: element.min }
    end

    def required_sections_data_codes
      composition_sections.filter do |section|
        REQUIRED_SECTIONS_CODES.include?(section[:code])
      end
    end

    def optional_sections_data_codes
      composition_sections.filter do |section|
        OPTIONAL_SECTIONS_CODES.include?(section[:code])
      end
    end

    def recommended_sections_data_codes
      composition_sections.filter do |section|
        RECOMMENDED_SECTIONS_CODES.include?(section[:code])
      end
    end

    def build_section_resources(section_data)
      resources = {}
      section_data[:entries].each do |entry|
        entry[:profiles].each do |profile|
          requirements = requirements_for_profile(profile)
          resources[profile] = { 'requirements' => requirements }
        end
      end
      resources
    end

    def requirements_for_profile(profile)
      filter = @resources_filters.find { |f| f[:resource_profile] == profile }
      filter ? filter[:filters] : []
    end

    # Populates @profiles with AU PS StructureDefinitions (url, name, title, required).
    #
    # @return [void]
    def extract_profiles
      @profiles = main_profiles.map do |profile|
        {
          url: profile.url.to_s,
          name: profile.name,
          title: profile.title,
          required: profile_required?(profile)
        }
      end
    end

    # Returns whether the given AU PS StructureDefinition is required.
    #
    # @param profile [FHIR::StructureDefinition] AU PS StructureDefinition
    # @return [Boolean] true if the profile URL is in {Generator::Constants::REQUIRED_PROFILES}
    def profile_required?(profile)
      REQUIRED_PROFILES.include?(profile.url.to_s)
    end

    # StructureDefinitions from the IG whose URL is an AU PS profile
    # (http://hl7.org.au/fhir/ps/StructureDefinition/...)
    #
    # @return [Array<FHIR::StructureDefinition>]
    def main_profiles
      @ig_resources.filter do |resource|
        next unless resource.resourceType == 'StructureDefinition'

        resource.url.to_s.include?('http://hl7.org.au/fhir/ps/StructureDefinition/')
      end
    end

    # Populates @composition_optional_ms_elements with mustSupport elements where min is 0.
    #
    # @return [void]
    def extract_optional_all_ms_elements
      extract_ms_elements_by_predicate(->(element) { element.min.zero? })
    end

    def path_is_not_slice?(path)
      !composition_mandatory_ms_slices_paths.include?(path) && !composition_optional_ms_slices_paths.include?(path)
    end

    def extract_optional_ms_elements
      @composition_optional_ms_elements = extract_optional_all_ms_elements.filter do |path|
        path_is_not_slice?(path) && !path.include?('.') && path != 'section'
      end + ['event']
      @composition_optional_ms_sub_elements = extract_optional_all_ms_elements.filter do |path|
        path_is_not_slice?(path) && path.include?('.') && !SUB_ELEMENTS_TO_SKIP.include?(path)
      end
      @composition_optional_ms_slices = composition_optional_ms_slices
    end

    # Populates @composition_mandatory_ms_elements with mustSupport elements where min > 0.
    #
    # @return [void]
    def extract_required_all_ms_elements
      extract_ms_elements_by_predicate(->(element) { element.min.positive? })
    end

    def extract_required_ms_elements
      @composition_mandatory_ms_elements = extract_required_all_ms_elements.filter do |path|
        path_is_not_slice?(path) && !path.include?('.') && path != 'section'
      end
      @composition_mandatory_ms_sub_elements = extract_required_all_ms_elements.filter do |path|
        path_is_not_slice?(path) && path.include?('.') && !SUB_ELEMENTS_TO_SKIP.include?(path)
      end
      @composition_mandatory_ms_slices = composition_mandatory_ms_slices
    end

    # Filters Composition mustSupport elements (no slices) by predicate and returns path suffixes.
    # Uses element.path so suffixes are relative to Composition (e.g. subject.reference), not the base type.
    #
    # @param predicate [Proc] Called with each element; keeps element when truthy (e.g. min.zero?, min.positive?)
    # @return [Array<String>] Sorted unique paths with "Composition." prefix removed (e.g. +subject.reference+)
    def extract_ms_elements_by_predicate(predicate)
      elements = composition_extract_ms_elements_without_slices.filter do |element|
        predicate.call(element)
      end
      elements.map do |element|
        element.path.gsub('Composition.', '')
      end.uniq.sort
    end

    # Returns Composition snapshot elements that are mustSupport, non-sliced, and under Composition.
    # Uses element.path (profile path) not element.base.path, so inherited sub-elements like
    # Composition.subject.reference are included (base.path would be Reference.reference).
    #
    # @return [Array<FHIR::Element>] Snapshot elements; empty if no Composition StructureDefinition
    def composition_extract_ms_elements_without_slices
      composition_structure_definition = get_structure_definition_by_type('Composition')
      return [] if composition_structure_definition.nil?

      elements = composition_structure_definition.snapshot.element
      elements.filter { |element| ms_composition_path?(element) }
    end

    def ms_composition_path?(element)
      element.mustSupport == true && !element.path.include?(':') && element.path.include?('Composition.')
    end

    def all_ms_elements_related_to_slice(slice)
      composition_structure_definition = get_structure_definition_by_type('Composition')
      return [] if composition_structure_definition.nil?

      elements = composition_structure_definition.snapshot.element
      elements.filter do |element|
        ms_composition_path?(element) && element.path.include?(slice)
      end
    end

    def composition_mandatory_ms_slices
      composition_extract_slices.filter { |slice| slice[:mustSupport] == true && slice[:min].positive? }
    end

    def composition_mandatory_ms_slices_paths
      composition_mandatory_ms_slices.map { |slice| slice[:path] }
    end

    def composition_optional_ms_slices
      composition_extract_slices.filter { |slice| slice[:mustSupport] == true && slice[:min].zero? }
    end

    def composition_optional_ms_slices_paths
      composition_optional_ms_slices.map { |slice| slice[:path] }
    end

    def composition_extract_slices
      composition_structure_definition = get_structure_definition_by_type('Composition')
      return [] if composition_structure_definition.nil?

      elements = composition_structure_definition.snapshot.element
      filtered_elements = elements.filter { |element| element_is_slice?(element) }
      filtered_elements.map { |element| build_metadata_for_slice(element) }
    end

    def build_metadata_for_slice(element)
      related = all_ms_elements_related_to_slice(element.path)
      base = element.path
      slice_metadata_base(element).merge(
        mandatory_ms_sub_elements: slice_relative_sub_paths(related, base, &:zero?),
        optional_ms_sub_elements: slice_relative_sub_paths(related, base, &:positive?)
      )
    end

    def slice_metadata_base(element)
      {
        path: element.path.gsub('Composition.', ''),
        sliceName: element.sliceName,
        min: element.min,
        max: element.max,
        mustSupport: element.mustSupport
      }
    end

    def slice_relative_sub_paths(related_elements, base_path, &min_pred)
      picked = related_elements.filter { |el| min_pred.call(el.min) }
      paths = picked.map { |el| el.path.gsub(base_path, '').gsub('.', '') }
      paths.reject(&:empty?)
    end

    def element_is_slice?(element)
      element.id.include?(':') && element&.sliceName &&
        !element.path.include?('section') &&
        !element.path.include?('extension')
    end

    # Returns IG resources whose resourceType matches the given type.
    #
    # @param type [String] FHIR resource type (e.g. +StructureDefinition+)
    # @return [Array<FHIR::Model>]
    def get_resources_by_type(type)
      @ig_resources.filter do |resource|
        resource.resourceType == type
      end
    end

    # Finds the StructureDefinition for a logical resource type (e.g. Composition, Patient).
    #
    # @param type [String] Logical type (e.g. +Composition+)
    # @return [FHIR::StructureDefinition, nil]
    def get_structure_definition_by_type(type)
      get_resources_by_type('StructureDefinition').find do |resource|
        resource.type == type
      end
    end

    # Finds a StructureDefinition in ig_resources whose canonical URL matches the given profile.
    # Matches by URL with or without version (canonical form "url|version").
    #
    # @param profile_url [String] Canonical profile URL (e.g. from Reference.type.targetProfile)
    # @param entry_id [String, nil] Optional entry element id for error context
    # @return [FHIR::StructureDefinition]
    # @raise [RuntimeError] when no StructureDefinition in ig_resources has this profile URL
    def get_structure_definition_by_profile(profile_url, entry_id = nil)
      base_url = profile_url.to_s.split('|').first
      sd = find_structure_definition_by_base_url(base_url)
      return sd if sd

      available = structure_definition_urls
      raise profile_not_found_error(profile_url, entry_id, available)
    end

    # Finds a StructureDefinition by canonical base URL (version stripped).
    #
    # @param base_url [String] Canonical URL without version (e.g. +http://hl7.org/fhir/StructureDefinition/Patient+)
    # @return [FHIR::StructureDefinition, nil]
    def find_structure_definition_by_base_url(base_url)
      get_resources_by_type('StructureDefinition').find do |resource|
        resource.url.to_s.split('|').first == base_url
      end
    end

    # Collects all non-empty canonical URLs from StructureDefinitions in the IG.
    #
    # @return [Array<String>] Sorted list of URL strings
    def structure_definition_urls
      get_resources_by_type('StructureDefinition').map { |r| r.url.to_s }.reject(&:empty?).sort
    end

    # Builds the error message when a profile has no matching StructureDefinition.
    #
    # @param profile_url [String] Requested profile URL
    # @param entry_id [String, nil] Optional entry id for context
    # @param available [Array<String>] List of available StructureDefinition URLs
    # @return [String] Error message suitable for RuntimeError
    def profile_not_found_error(profile_url, entry_id, available)
      context = entry_id ? " (entry: #{entry_id})" : ''
      hint = 'Add JSON via ADDITIONAL_IG_RESOURCES or additional_resources_path.'
      sample = available.join(', ')
      "No StructureDefinition found in IG resources for profile: #{profile_url.inspect}#{context}. " \
        "Ensure the IG includes it or #{hint} " \
        "Available URLs (#{available.size}): #{sample}"
    end

    # Populates @composition_sections from the Composition StructureDefinition.
    # No-op when no Composition StructureDefinition is present in the IG.
    #
    # @return [void]
    def generate_metadata_for_composition
      composition_structure_definition = get_structure_definition_by_type('Composition')
      return if composition_structure_definition.nil?

      elements = composition_structure_definition.snapshot.element
      sections = elements.filter do |element|
        element.path == 'Composition.section' && !element.sliceName.nil?
      end

      sections.each do |section|
        @composition_sections << build_section_data(section, elements)
      end
    end

    # Builds a full section metadata hash including code and entries.
    #
    # @param section [FHIR::Element] Snapshot element for Composition.section (with sliceName)
    # @param elements [Array<FHIR::Element>] All snapshot elements from the Composition StructureDefinition
    # @return [Hash] Section metadata hash including keys:
    #   :id, :short, :definition, :min, :max, :required, :mustSupport, :code, :entries
    def build_section_data(section, elements)
      basic_section_data = build_basic_section_data(section)
      {
        **basic_section_data,
        code: section_code(section.id, elements),
        entries: get_section_entry_data(elements, section.id)
      }
    end

    # Builds the basic section fields from a snapshot element (no code or entries).
    #
    # @param section [FHIR::Element] Snapshot element for Composition.section (with sliceName)
    # @return [Hash] Basic section fields:
    #   :id, :short, :definition, :min, :max, :required, :mustSupport
    def build_basic_section_data(section)
      {
        id: section.id,
        short: section.short,
        definition: section.definition,
        min: section.min,
        max: section.max,
        required: section.min.positive?,
        mustSupport: section.mustSupport || false,
        ms_elements: composition_ms_sections_elements
      }
    end

    # Extracts the LOINC (or other) section code from the section's +code+ element.
    #
    # @param section_id [String] Section element id (e.g. +Composition.section:sectionProblems+)
    # @param elements [Array<FHIR::Element>] All snapshot elements
    # @return [String, nil] First coding code from the section's pattern CodeableConcept, or nil if absent
    def section_code(section_id, elements)
      filtered_element = elements.find do |element|
        element.id == "#{section_id}.code"
      end
      return nil if filtered_element.nil?

      filtered_element.patternCodeableConcept.coding.first.code
    end

    # Collects entry elements for a section and builds entry metadata for each.
    #
    # @param elements [Array<FHIR::Element>] Snapshot elements
    # @param section_id [String] Section element id (e.g. +Composition.section:sectionProblems+)
    # @return [Array<Hash>] Entry metadata hashes (see {#build_section_entry_data})
    def get_section_entry_data(elements, section_id)
      entries = elements.filter do |element|
        element.id.include?("#{section_id}.entry:")
      end

      entries.map do |entry|
        build_section_entry_data(entry)
      end
    end

    # Builds entry metadata from a section entry snapshot element (id, cardinality, mustSupport, profiles).
    #
    # @param entry [FHIR::Element] Snapshot element for section entry (e.g. Composition.section:...entry:problem)
    # @return [Hash] Entry metadata hash including keys:
    #   :id, :min, :max, :required, :mustSupport, :profiles
    def build_section_entry_data(entry)
      {
        id: entry.id,
        min: entry.min,
        max: entry.max,
        required: entry.min.positive?,
        mustSupport: entry.mustSupport || false,
        profiles: get_section_entry_profiles(entry.id, entry)
      }
    end

    # Resolves Reference type targetProfile URLs to "resourceType|profile" using IG StructureDefinitions.
    #
    # @param entry_id [String] Entry element id (for error messages when profile is missing)
    # @param element [FHIR::Element] Snapshot element with type Reference and targetProfile
    # @return [Array<String>] Strings in the form "resourceType|profile" for each target profile
    # @raise [RuntimeError] when no StructureDefinition matches a targetProfile.
    #   See {#get_structure_definition_by_profile}.
    def get_section_entry_profiles(entry_id, element)
      ref_types = element.type&.select { |t| t.code == 'Reference' } || []
      profile_urls = ref_types.flat_map(&:targetProfile).to_a.compact

      profile_urls.map do |profile_url|
        sd = get_structure_definition_by_profile(profile_url, entry_id)
        "#{sd.type}|#{profile_url}"
      end
    end

    def normalize_path_to_hash(path)
      { expression: path, label: path }
    end

    def optional_ms_elements
      @composition_optional_ms_elements.map { |element| normalize_path_to_hash(element) }
    end

    def optional_ms_sub_elements
      @composition_optional_ms_sub_elements.map { |element| normalize_path_to_hash(element) }
    end

    def au_ps_profiles_mapping_required
      required = @profiles.filter { |profile| profile[:required] }
      required.to_h { |profile| [profile[:url], profile[:name]] }
    end

    def au_ps_profiles_mapping_other
      other = @profiles.filter { |profile| !profile[:required] }
      other.to_h { |profile| [profile[:url], profile[:name]] }
    end

    def build_metadata_for_subject
      SUBJECT_PROFILE_REFS.map { |profile| metadata_hash_for_profile_ref(profile) }
    end

    def build_metadata_for_custodian
      # Custodian is only AU PS Organization
      build_metadata_for_mapping(CUSTODIAN_PROFILE_REFS)
    end

    def build_metadata_for_attester
      # attester.party: AU PS Patient | RelatedPerson | Practitioner | PractitionerRole | Organization (no Device)
      build_metadata_for_mapping(ATTESTER_PROFILE_REFS)
    end

    def build_metadata_for_author
      # AU PS Practitioner, AU PS PractitionerRole, AU PS Patient, AU PS RelatedPerson,
      # AU PS Organization profiles or Device resource
      build_metadata_for_mapping(AUTHOR_PROFILE_REFS)
    end

    def build_metadata_for_mapping(profile_refs)
      profile_refs.map { |profile| metadata_hash_for_profile_ref(profile) }
    end

    def metadata_hash_for_profile_ref(profile)
      url = profile.split('|')[1]
      sd = get_structure_definition_by_profile(url)
      {
        resource_type: sd.type,
        profile: url,
        elements: get_elements_from_structure_definition(sd),
        slices: get_extension_slices_from_structure_definition(sd)
      }
    end

    def get_extension_slices_from_structure_definition(sd_data)
      # Return mandatory MS extension slices
      sd_decorator = StructureDefinitionDecorator.new(sd_data.to_hash)
      extension_slices = sd_decorator.extension_slices
      filtered_extension_slices = extension_slices.filter { |element| element.mustSupport == true }
      filtered_extension_slices.map do |element|
        build_normalized_element_data(element, sd_decorator)
      end.uniq
    end

    def build_normalized_element_data(element, sd_decorator)
      first_element_type = element&.type&.first
      profile = first_element_type&.profile&.first || ''
      {
        id: element.id,
        expression: element.path.gsub("#{sd_decorator.type}.", ''),
        label: element.sliceName,
        min: element.min,
        max: element.max,
        profile: profile
      }
    end

    def get_elements_from_structure_definition(sd_data)
      structure_definition_data = StructureDefinitionDecorator.new(sd_data.to_hash)
      elements = structure_definition_data.simple_elements(include_str: "#{sd_data.type}.")
      filtered_elements = elements.reject { |element| element.id.include?(':') }
      filtered_elements.map do |element|
        {
          id: element.id,
          expression: element.path.gsub("#{sd_data.type}.", ''),
          min: element.min
        }
      end.uniq
    end

    private :reset_composition_metadata_ivars!, :metadata_dump_sections, :metadata_dump_ms_elements,
            :metadata_dump_tail, :section_element_expression_min, :slice_metadata_base,
            :slice_relative_sub_paths, :ms_composition_path?, :metadata_hash_for_profile_ref
  end
  # rubocop:enable Metrics/ClassLength
end
