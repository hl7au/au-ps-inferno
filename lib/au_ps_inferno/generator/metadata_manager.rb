# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require_relative 'metadata_producer'

class Generator
  # Builds and persists metadata for Composition sections from IG resources.
  #
  # Delegates extraction of Composition StructureDefinition sections and their entry
  # constraints (profiles, cardinality, mustSupport, section codes) to {CompositionMetadataProducer},
  # then assembles and serializes the result to YAML.
  # Output hash keys: +composition_sections+, +composition_mandatory_ms_elements+,
  # +composition_optional_ms_elements+, +profiles+.
  #
  # @see CompositionMetadataProducer for the IG resource extraction logic
  class CompositionMetadataManager
    # @return [Array<Hash>] Array of section metadata hashes
    attr_reader :composition_sections

    # Initializes a CompositionMetadataManager for the given IG resources.
    #
    # @param ig_resources [InfernoSuiteGenerator::Generator::IGResources] Parsed IG resources
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

    # Runs {CompositionMetadataProducer} against the IG resources and stores the result (in-memory only).
    # Populates the internal composition sections and related metadata used by {#save_to_file}.
    #
    # @return [void]
    def initiate_build
      @producer = CompositionMetadataProducer.new(@ig_resources).build!
      apply_producer_data(@producer)
      normalize_sections_data
    end

    def apply_producer_data(producer)
      @composition_sections = producer.composition_sections
      @composition_mandatory_ms_elements = producer.composition_mandatory_ms_elements
      @composition_mandatory_ms_sub_elements = producer.composition_mandatory_ms_sub_elements
      @composition_mandatory_ms_slices = producer.composition_mandatory_ms_slices
      @composition_optional_ms_elements = producer.composition_optional_ms_elements
      @composition_optional_ms_sub_elements = producer.composition_optional_ms_sub_elements
      @composition_optional_ms_slices = producer.composition_optional_ms_slices
      @profiles = producer.profiles
      @resources_filters = producer.resources_filters
    end

    def normalize_sections_data
      @normalized_sections_data = @composition_sections.map do |section|
        normalize_section_data(section[:id])
      end
    end

    def composition_metadata_to_dump
      raise 'initiate_build must be called before composition_metadata_to_dump' if @producer.nil?

      metadata_dump_sections.merge(metadata_dump_ms_elements).merge(resources_filters: @resources_filters)
    end

    def metadata_dump_sections
      {
        composition_sections: @composition_sections,
        subject: @producer.build_metadata_for_subject,
        author: @producer.build_metadata_for_author,
        custodian: @producer.build_metadata_for_custodian,
        attester: @producer.build_metadata_for_attester
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

    def normalize_path_to_hash(path)
      { expression: path, label: path }
    end

    def mandatory_ms_sub_elements
      @composition_mandatory_ms_sub_elements.map { |element| normalize_path_to_hash(element) }
    end

    private :reset_composition_metadata_ivars!, :apply_producer_data, :metadata_dump_sections,
            :metadata_dump_ms_elements
  end
end
