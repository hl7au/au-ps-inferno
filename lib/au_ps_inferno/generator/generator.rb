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
    {
      name: 'Bundle validation',
      groups: [
        {
          name: 'Bundle has Must Support elements',
          tests: [
            {
              name: 'Must Support elements SHALL be populated when an element value is known and allowed to share'
            }
          ]
        },
        {
          name: 'Composition Must Support elements',
          tests: [
            {
              name: 'Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share'
            },
            {
              name: 'Optional Must Support elements SHALL be correctly populated if a value is known '
            },
            {
              name: 'Must Support sub-elements of a complex element SHALL be correctly populated if a value is known'
            },
            {
              name: 'Optional Must Support careProvisioningEvent slice SHALL be populated if a value is known'
            }
          ]
        },
        {
          name: 'Composition Mandatory Sections',
          tests: [
            {
              name: 'Mandatory section SHALL be correctly populated if a value is known (one for each mandatory section)'
            },
            {
              name: 'Mandatory section SHALL be capable of populating section.entry with the referenced profiles, and SHOULD correctly populate section.entry if a value is known (one for each mandatory section).'
            }
          ]
        },
        {
          name: 'Composition Recommended Sections',
          tests: [
            {
              name: 'Recommended sections SHOULD be correctly populated if a value is known (one for each recommended section)'
            }
          ]
        },
        {
          name: 'Composition Optional Sections',
          tests: [
            {
              name: 'Optional section MAY be correctly populated if a value is known (one for each optional section) '
            }
          ]
        },
        {
          name: 'Composition Undefined Sections',
          tests: [
            {
              name: 'Undefined sections MAY be populated if a value is known (one for each undefined section)'
            }
          ]
        }
      ]
    },
    {
      name: 'Retrieve Bundle validation',
      groups: []
    },
    {
      name: 'Generate Bundle using IPS $summary validation',
      groups: []
    }
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
    special_characters = ['$', '.', ',', '(', ')']
    string.gsub(Regexp.union(special_characters), '')
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

  # Builds a path under PATH_BASE/suite_version. Pass segments and optional filename (with .rb).
  def versioned_path(*segments, filename: nil)
    parts = [PATH_BASE, @suite_version, *segments]
    parts << filename if filename
    File.join(*parts)
  end

  def group_description(name)
    "Displays information about #{name} in the Composition resource."
  end

  def generate_primitive_group(generic_bundle_group, high_order_class_name, high_order_group_id,
                               high_order_group_file_name)
    config = primitive_group_config(generic_bundle_group, high_order_class_name, high_order_group_id,
                                    high_order_group_file_name)
    PrimitiveGroup.new(config).generate
  end

  def primitive_group_config(generic_bundle_group, high_order_class_name, high_order_group_id,
                             high_order_group_file_name)
    generic_id = build_id(generic_bundle_group[:name])
    file_name = generic_id
    high_order_group_id = :"#{high_order_group_id}_#{generic_id}"
    high_order_group_class_name = "#{high_order_class_name}#{build_class_name(generic_bundle_group[:name])}"
    # generic_bundle_group[:tests].map do |test|
    #   generate_primitive_test(high_order_group_class_name, high_order_group_id, file_name, test)
    # end
    {
      class_name: high_order_group_class_name,
      title: generic_bundle_group[:name],
      description: group_description(generic_bundle_group[:name]),
      id: high_order_group_id,
      output_file_path: versioned_path(high_order_group_file_name, file_name, filename: "#{file_name}.rb")
      # tests: tests
    }
  end

  def generate_primitive_test(group_class_name, group_id, group_file_name, test)
    test_id = "#{group_id}_#{build_id(test[:name])}"
    test_config = {
      class_name: "#{group_class_name}#{build_class_name(test[:name])}",
      title: test[:name],
      id: test_id,
      output_file_path: versioned_path(group_file_name, test_id, filename: "#{test_id}.rb")
    }
    PrimitiveTest.new(test_config).generate
  end

  def generate_high_order_group(high_order_group, suite_class_name, suite_id)
    high_order_group_id = :"#{suite_id}_#{build_id(high_order_group[:name])}"
    high_order_group_file_name = build_id(high_order_group[:name]).to_s
    high_order_class_name = "#{suite_class_name}#{build_class_name(high_order_group[:name])}"
    generic_bundle_groups = high_order_group[:groups].map do |generic_bundle_group|
      generate_primitive_group(generic_bundle_group, high_order_class_name, high_order_group_id,
                               high_order_group_file_name)
    end
    config = high_order_group_config(high_order_group, high_order_class_name, high_order_group_id, high_order_group_file_name,
                                     generic_bundle_groups)
    HighOrderGroup.new(config).generate
  end

  def high_order_group_config(high_order_group, high_order_class_name, high_order_group_id, high_order_group_file_name,
                              generic_bundle_groups)
    {
      class_name: high_order_class_name,
      title: high_order_group[:name],
      description: group_description(high_order_group[:name]),
      id: high_order_group_id,
      groups: generic_bundle_groups,
      output_file_path: versioned_path(high_order_group_file_name, filename: "#{high_order_group_file_name}.rb")
    }
  end

  def generate_primitive_suite
    ig_suite_version = ig_version_to_suite_version(@suite_version)
    suite_class_name = "AUPSSuite#{build_class_name(ig_suite_version)}"
    suite_id = :"suite_#{build_id(ig_suite_version)}"
    high_order_groups = HIGH_ORDER_GROUPS.map do |high_order_group|
      generate_high_order_group(high_order_group, suite_class_name, suite_id)
    end
    config = suite_primitive_config(suite_class_name, suite_id, ig_suite_version, high_order_groups)
    SuitePrimitive.new(config).generate
  end

  def suite_primitive_config(suite_class_name, suite_id, ig_suite_version, high_order_groups)
    {
      suite_version: ig_suite_version,
      class_name: suite_class_name,
      title: @suite_version,
      description: "Suite for #{@suite_version}",
      id: suite_id,
      groups: high_order_groups,
      output_file_path: versioned_path("#{ig_suite_version}_suite.rb")
    }
  end

  def new_generate
    @resources_manager.extract
    save_metadata_to_version_folder
    generate_primitive_suite
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
