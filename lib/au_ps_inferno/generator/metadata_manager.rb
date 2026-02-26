# frozen_string_literal: true

require 'yaml'
require_relative 'constants'

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

    # Initializes a MetadataManager for the given IG resources.
    #
    # @param ig_resources [Array<FHIR::Model>] Parsed IG resources (e.g. from IGResourcesExtractor#ig_resources)
    def initialize(ig_resources)
      @ig_resources = ig_resources
      @composition_sections = []
      @composition_mandatory_ms_elements = []
      @composition_optional_ms_elements = []
      @profiles = []
      @resources_filters = {}
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
      File.write(file_path, YAML.dump(
                              {
                                composition_sections: @composition_sections,
                                composition_mandatory_ms_elements: @composition_mandatory_ms_elements,
                                composition_optional_ms_elements: @composition_optional_ms_elements,
                                profiles: @profiles,
                                resources_filters: @resources_filters
                              }
                            ))
    end

    def normalize_section_data(section_id)
      section_data = @composition_sections.find { |section| section[:id] == section_id }
      return section_data if section_data.nil?

      {
        'code' => section_data[:code],
        'display' => section_data[:short],
        'resources' => build_section_resources(section_data)
      }
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
    def extract_optional_ms_elements
      @composition_optional_ms_elements = extract_ms_elements_by_predicate(->(element) { element.min.zero? })
    end

    # Populates @composition_mandatory_ms_elements with mustSupport elements where min > 0.
    #
    # @return [void]
    def extract_required_ms_elements
      @composition_mandatory_ms_elements = extract_ms_elements_by_predicate(->(element) { element.min.positive? })
    end

    # Filters Composition mustSupport elements (no slices) by predicate and returns path suffixes.
    #
    # @param predicate [Proc] Called with each element; keeps element when truthy (e.g. min.zero?, min.positive?)
    # @return [Array<String>] Sorted unique paths with "Composition." prefix removed (e.g. +section.title+)
    def extract_ms_elements_by_predicate(predicate)
      elements = composition_extract_ms_elements_without_slices.filter do |element|
        predicate.call(element)
      end
      elements.map do |element|
        element.base.path.gsub('Composition.', '')
      end.uniq.sort
    end

    # Returns Composition snapshot elements that are mustSupport, non-sliced, and under Composition.
    #
    # @return [Array<FHIR::Element>] Snapshot elements; empty if no Composition StructureDefinition
    def composition_extract_ms_elements_without_slices
      composition_structure_definition = get_structure_definition_by_type('Composition')
      return [] if composition_structure_definition.nil?

      elements = composition_structure_definition.snapshot.element
      elements.filter do |element|
        element.mustSupport == true && !element.base.path.include?(':') && element.base.path.include?('Composition.')
      end
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
        mustSupport: section.mustSupport || false
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
  end
  # rubocop:enable Metrics/ClassLength
end
