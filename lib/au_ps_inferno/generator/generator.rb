# frozen_string_literal: true

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'
require_relative 'retrieve_bundle_group_generator'
require_relative 'retrieve_cs_group_generator'
require_relative 'summary_bundle_group_generator'
require_relative 'validation_group_generator'
require_relative 'sections_validation_group_generator'
require_relative 'test_file_generator'
require_relative 'version_suffix'
require_relative 'primitive_test'
require_relative 'primitive_group'
require_relative 'high_order_group'
require_relative 'suite_primitive'

# Generator for test suites targeting AU PS and IPS implementation guides.
#
# This class automates extraction and persistence of IG resource metadata for use in test suite
# generation, including support for additional FHIR resource folders.
#
# @example Basic usage
#   generator = Generator.new('/path/to/ig')
#   generator.generate
#
# @example With extra folder containing additional FHIR resources (e.g. extra StructureDefinitions)
#   generator = Generator.new('/path/to/ig', additional_resources_path: 'path/to/extra-ig-resources')
#   generator.generate
class Generator
  PATH_BASE = 'lib/au_ps_inferno'
  HIGH_ORDER_GROUPS = [
    'Bundle validation',
    'Retrieve Bundle validation',
    'Generate Bundle using IPS $summary validation'
  ].freeze
  GENERIC_BUNDLE_GROUPS = [
    'Bundle has Must Support elements',
    'Composition Must Support elements',
    'Composition Mandatory Sections',
    'Composition Recommended Sections',
    'Composition Optional Sections',
    'Composition Other Sections'
  ].freeze
  # Constructs a new Generator.
  #
  # @param ig_path [String]
  #   Path to the FHIR IG package archive (.tar.gz or .tgz).
  # @param additional_resources_path [String, nil]
  #   Optional: Path to a directory containing additional FHIR resources in JSON form
  #   (such as StructureDefinition, SearchParameter, etc.) to supplement those in the package.
  def initialize(ig_path, additional_resources_path: nil)
    @ig_path = ig_path
    @suite_version = Generator.suite_version_from_ig_path(ig_path)
    @version_suffix = Generator.version_suffix(File.basename(ig_path))
    @resources_manager = IGResourcesExtractor.new(
      ig_path,
      additional_resources_path: additional_resources_path
    )
    @metadata = MetadataManager.new(@resources_manager.ig_resources)
  end

  # Runs the generator: extracts IG resources, writes metadata, generates bundle and section groups,
  # and generates the suite file.
  #
  # @return [void]
  def generate
    new_generate
    # @resources_manager.extract
    # save_metadata_to_version_folder
    # group_infos = run_bundle_and_validation_generators
    # section_gen = SectionsValidationGroupGenerator.new(@metadata, @version_suffix, @suite_version)
    # section_gen.generate
    # generate_suite(group_infos + [section_gen.suite_group_info])
  end

  private

  def camel_case(string)
    string.split.map(&:capitalize).join
  end

  def remove_special_characters(string)
    string.gsub('$', '')
  end

  def build_class_name(string)
    camel_case(remove_special_characters(string)).gsub(' ', '')
  end

  def build_id(string)
    remove_special_characters(string.gsub(' ', '_')).downcase
  end

  def ig_version_to_suite_version(ig_version)
    ig_version.gsub('-', '').gsub('.', '')
  end

  def new_generate
    @resources_manager.extract
    save_metadata_to_version_folder
    high_order_groups = HIGH_ORDER_GROUPS.map do |high_order_group|
      high_order_group_file_name = "#{build_id(high_order_group)}_high_order_group"
      generic_bundle_groups = GENERIC_BUNDLE_GROUPS.map do |generic_bundle_group|
        generic_bundle_group_file_name = "#{build_id(generic_bundle_group)}_generic_bundle_group"
        generic_bundle_group_config = {
          class_name: "#{build_class_name(generic_bundle_group)}GenericBundleGroup",
          title: generic_bundle_group,
          description: "Displays information about #{generic_bundle_group} in the Composition resource.",
          id: :"#{build_id(generic_bundle_group)}_generic_bundle_group",
          output_file_path: "#{PATH_BASE}/#{@suite_version}/#{high_order_group_file_name}/#{generic_bundle_group_file_name}/#{generic_bundle_group_file_name}.rb"
        }
        PrimitiveGroup.new(generic_bundle_group_config).generate
      end
      high_order_group_config = {
        class_name: "#{build_class_name(high_order_group)}HighOrderGroup",
        title: high_order_group,
        description: "Displays information about #{high_order_group} in the Composition resource.",
        id: :"#{build_id(high_order_group)}",
        groups: generic_bundle_groups,
        output_file_path: "#{PATH_BASE}/#{@suite_version}/#{high_order_group_file_name}/#{high_order_group_file_name}.rb"
      }
      HighOrderGroup.new(high_order_group_config).generate
    end
    ig_suite_version = ig_version_to_suite_version(@suite_version)
    suite_config = {
      suite_version: ig_suite_version,
      class_name: "Suite#{build_class_name(ig_suite_version)}",
      title: @suite_version,
      description: "Suite for #{@suite_version}",
      id: :"suite_#{build_id(ig_suite_version)}",
      groups: high_order_groups,
      output_file_path: "#{PATH_BASE}/#{@suite_version}/#{ig_suite_version}_suite.rb"
    }
    SuitePrimitive.new(suite_config).generate
    # test_config = {
    #   class_name: 'AUPSRetrieveBundleCompositionMandatorySection100ballot',
    #   title: 'AU PS Composition Mandatory Sections (Must Have)',
    #   description: 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.',
    #   id: :au_ps_retrieve_bundle_composition_mandatory_sections_100ballot,
    #   commands: ['Hello,', 'World!'],
    #   imports: %w[import1 import2],
    #   output_file_path: "#{PATH_BASE}/au_ps_retrieve_bundle_composition_mandatory_sections_100ballot.rb"
    # }
    # test_1 = PrimitiveTest.new(test_config).generate
    # tests = [test_1]
    # group_config = {
    #   class_name: 'AUPSRetrieveBundleCompositionMandatorySection100ballotGroup',
    #   title: 'AU PS Composition Mandatory Sections (Must Have)',
    #   description: 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.',
    #   id: :au_ps_retrieve_bundle_composition_mandatory_sections_100ballot_group,
    #   tests: tests,
    #   output_file_path: "#{PATH_BASE}/au_ps_retrieve_bundle_composition_mandatory_sections_100ballot_group.rb"
    # }
    # group_1 = PrimitiveGroup.new(group_config).generate
    # groups = [group_1]
    # high_order_group_config = {
    #   class_name: 'AUPSRetrieveBundleCompositionMandatorySection100ballotHighOrderGroup',
    #   title: 'AU PS Composition Mandatory Sections (Must Have)',
    #   description: 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.',
    #   id: :au_ps_retrieve_bundle_composition_mandatory_sections_100ballot_high_order_group,
    #   groups: groups,
    #   output_file_path: "#{PATH_BASE}/au_ps_retrieve_bundle_composition_mandatory_sections_100ballot_high_order_group.rb"
    # }
    # high_order_group = HighOrderGroup.new(high_order_group_config).generate
    # suite_config = {
    #   class_name: 'AUPSRetrieveBundleCompositionMandatorySection100ballotSuite',
    #   title: 'AU PS Composition Mandatory Sections (Must Have)',
    #   description: 'Displays information about mandatory sections (Allergies and Intolerances, Medication Summary, Problem List) in the Composition resource, including the entry references within each section.',
    #   id: :au_ps_retrieve_bundle_composition_mandatory_sections_100ballot_suite,
    #   groups: [high_order_group],
    #   suite_version: '1.0.0-ballot',
    #   output_file_path: "#{PATH_BASE}/au_ps_retrieve_bundle_composition_mandatory_sections_100ballot_suite.rb"
    # }
    # SuitePrimitive.new(suite_config).generate
  end

  # Runs retrieve bundle, retrieve CS, summary, and validation group generators; returns suite_group_info.
  # @return [Array<Hash>] suite_group_info hashes for suite template
  def run_bundle_and_validation_generators
    [
      ValidationGroupGenerator,
      RetrieveCSGroupGenerator,
      RetrieveBundleGroupGenerator,
      SummaryBundleGroupGenerator
    ].map do |gen_class|
      gen = gen_class.new(@metadata, @version_suffix, @suite_version)
      gen.generate
      gen.suite_group_info
    end
  end

  def save_metadata_to_version_folder
    return if @suite_version.empty?

    metadata_path = File.join(File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version)), 'metadata.yaml')
    @metadata.save_to_file(metadata_path)
  end

  def generate_suite(groups)
    return if @suite_version.empty?

    config = suite_config(groups)
    Generator::TestFileGenerator.new(config).generate
  end

  def suite_config(groups)
    suite_output_base = File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version))
    {
      template_file_path: 'suite.rb.erb',
      output_file_path: 'au_ps_suite.rb',
      output_base: suite_output_base,
      attributes: suite_attributes(groups)
    }
  end

  def suite_attributes(groups)
    { groups: groups, version_suffix: @version_suffix, suite_version: @suite_version }
  end
end
