# frozen_string_literal: true

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'
require_relative 'naming'
require_relative 'suite_structure'
require_relative 'test_config_registry'
require_relative 'retrieve_cs_group_generator'
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

  include Naming

  # High-order groups are built from SuiteStructure (single source of truth).
  # See SuiteStructure and TestConfigRegistry for adding new groups or test types.
  HIGH_ORDER_GROUPS = SuiteStructure.expand_high_order_groups.freeze

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
  end

  private

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
    "Validates #{name}."
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
    tests = generic_bundle_group[:tests].map do |test|
      generate_primitive_test(high_order_group_class_name, high_order_group_id, file_name, high_order_group_file_name,
                              test)
    end
    config = {
      class_name: high_order_group_class_name,
      title: generic_bundle_group[:name],
      description: generic_bundle_group[:description] || group_description(generic_bundle_group[:name]),
      id: high_order_group_id,
      output_file_path: versioned_path(high_order_group_file_name, filename: "#{file_name}.rb"),
      tests: tests
    }
    config[:optional] = generic_bundle_group[:optional] if generic_bundle_group.key?(:optional)
    config[:run_as_group] = generic_bundle_group[:run_as_group] if generic_bundle_group.key?(:run_as_group)
    config
  end

  def generate_primitive_test(group_class_name, group_id, group_file_name, high_order_group_file_name, test)
    test_type_id = test[:id]
    unless test_type_id == :bundle_valid || TestConfigRegistry.registered?(test_type_id)
      raise "Unknown test type id: #{test_type_id.inspect}. Add it to TestConfigRegistry."
    end

    resolved_title = test[:title]
    resolved_description = test[:description]
    if test_type_id != :bundle_valid
      registry_config = TestConfigRegistry.config_for(test_type_id, @metadata)
      resolved_title ||= registry_config[:title]
      resolved_description ||= registry_config[:description]
    end
    if test_type_id == :bundle_valid && resolved_title.nil?
      raise 'Bundle validation test requires bundle_validation_title in high-order config.'
    end

    resolved_description ||= "Verifies that the resource meets the requirement: #{resolved_title}"

    test_id = "#{group_id}_#{build_id(test_type_id)}"
    test_config = {
      class_name: "#{group_class_name}#{build_class_name(resolved_title)}",
      title: resolved_title,
      description: resolved_description,
      id: test_id,
      output_file_path: versioned_path(high_order_group_file_name, group_file_name, filename: "#{test_id}.rb")
    }
    if test_type_id == :bundle_valid
      test_config[:base_class_name] = test[:base_class_name]
      test_config[:imports] = test[:imports]
      test_config[:ignore_commands] = test[:ignore_commands]
    elsif TestConfigRegistry.registered?(test_type_id)
      test_config.merge!(TestConfigRegistry.config_for(test_type_id, @metadata))
      test_config[:title] = resolved_title
      test_config[:description] = resolved_description
    end
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
    # Path for require_relative must be relative to the high-order group file's directory
    groups_with_relative_path = generic_bundle_groups.map { |g| g.merge(path: g[:path].split('/').last) }
    config = {
      class_name: high_order_class_name,
      title: high_order_group[:name],
      description: high_order_group[:description] || group_description(high_order_group[:name]),
      id: high_order_group_id,
      groups: groups_with_relative_path,
      output_file_path: versioned_path(high_order_group_file_name, filename: "#{high_order_group_file_name}.rb")
    }
    config[:optional] = high_order_group[:optional] if high_order_group.key?(:optional)
    config[:run_as_group] = high_order_group[:run_as_group] if high_order_group.key?(:run_as_group)
    config
  end

  def generate_primitive_suite
    ig_suite_version = ig_version_to_suite_version(@suite_version)
    suite_class_name = "AUPSSuite#{build_class_name(ig_suite_version)}"
    suite_id = :"suite_#{build_id(ig_suite_version)}"
    high_order_groups = HIGH_ORDER_GROUPS.map do |high_order_group|
      generate_high_order_group(high_order_group, suite_class_name, suite_id)
    end
    # sections_group = generate_sections_validation_group
    retrieve_cs_group = generate_retrieve_cs_group
    # all_groups = high_order_groups + [retrieve_cs_group].compact
    # retrieve_cs_group should be second in the all_groups array
    high_order_groups.insert(1, retrieve_cs_group) if retrieve_cs_group
    config = suite_primitive_config(suite_class_name, suite_id, ig_suite_version, high_order_groups)
    SuitePrimitive.new(config).generate
  end

  # Runs SectionsValidationGroupGenerator and returns suite group info in the same shape as
  # high-order groups ({ path:, id: }) for inclusion in the suite, or nil if suite_version is empty.
  def generate_sections_validation_group
    return nil if @suite_version.empty?

    section_gen = SectionsValidationGroupGenerator.new(@metadata, @version_suffix, @suite_version)
    section_gen.generate
    suite_group_info_to_path_id(section_gen.suite_group_info)
  end

  # Runs RetrieveCSGroupGenerator and returns suite group info in the same shape as
  # high-order groups ({ path:, id: }) for inclusion in the suite, or nil if suite_version is empty.
  def generate_retrieve_cs_group
    return nil if @suite_version.empty?

    gen = RetrieveCSGroupGenerator.new(@metadata, @version_suffix, @suite_version)
    gen.generate
    suite_group_info_to_path_id(gen.suite_group_info)
  end

  def suite_group_info_to_path_id(info)
    {
      path: info[:file_path].sub(/\.rb$/, ''),
      id: info[:attributes][:group_id].to_sym
    }
  end

  def suite_primitive_config(suite_class_name, suite_id, ig_suite_version, high_order_groups)
    {
      suite_version: ig_suite_version,
      class_name: suite_class_name,
      title: "AU PS #{@suite_version} Test Suite",
      description: "Validates AU PS (Australian Primary Care and Shared Health) bundles, compositions, sections, and server CapabilityStatement support for the #{@suite_version} implementation guide.",
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

  def save_metadata_to_version_folder
    return if @suite_version.empty?

    metadata_path = File.join(File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version)), 'metadata.yaml')
    @metadata.save_to_file(metadata_path)
  end
end
