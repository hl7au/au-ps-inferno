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
#
# rubocop:disable Metrics/ClassLength -- orchestration class; primitive helpers kept private below
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
    nested = nested_primitive_group_ids(generic_bundle_group, high_order_class_name, high_order_group_id)
    tests = map_primitive_tests(generic_bundle_group, nested[:class_name], nested[:group_id], nested[:file_name],
                                high_order_group_file_name)
    build_primitive_group_hash(generic_bundle_group: generic_bundle_group, nested_class_name: nested[:class_name],
                               nested_group_id: nested[:group_id], file_name: nested[:file_name],
                               high_order_group_file_name: high_order_group_file_name, tests: tests)
  end

  def nested_primitive_group_ids(generic_bundle_group, high_order_class_name, high_order_group_id)
    generic_id = build_id(generic_bundle_group[:name])
    {
      file_name: generic_id,
      group_id: :"#{high_order_group_id}_#{generic_id}",
      class_name: "#{high_order_class_name}#{build_class_name(generic_bundle_group[:name])}"
    }
  end

  def map_primitive_tests(generic_bundle_group, nested_class_name, nested_group_id, file_name,
                          high_order_group_file_name)
    generic_bundle_group[:tests].map do |test|
      generate_primitive_test(nested_class_name, nested_group_id, file_name, high_order_group_file_name, test)
    end
  end

  def build_primitive_group_hash(parts)
    g = parts.fetch(:generic_bundle_group)
    merge_optional_primitive_group_flags!(base_primitive_group_config(parts), g)
  end

  def base_primitive_group_config(parts)
    g = parts.fetch(:generic_bundle_group)
    ho_file, file_name = parts.values_at(:high_order_group_file_name, :file_name)
    {
      class_name: parts.fetch(:nested_class_name), title: g[:name],
      description: g[:description] || group_description(g[:name]), id: parts.fetch(:nested_group_id),
      output_file_path: versioned_path(ho_file, filename: "#{file_name}.rb"), tests: parts.fetch(:tests)
    }
  end

  def merge_optional_primitive_group_flags!(config, generic_bundle_group)
    config[:optional] = generic_bundle_group[:optional] if generic_bundle_group.key?(:optional)
    config[:run_as_group] = generic_bundle_group[:run_as_group] if generic_bundle_group.key?(:run_as_group)
    config
  end

  # rubocop:disable Metrics/MethodLength -- steps are clearer kept sequential
  def generate_primitive_test(group_class_name, group_id, group_file_name, high_order_group_file_name, test)
    test_type_id = test[:id]
    validate_primitive_test_type!(test_type_id)
    resolved_title, resolved_description = resolve_primitive_test_labels(test, test_type_id)
    ensure_bundle_valid_has_title!(test_type_id, resolved_title)
    resolved_description ||= primitive_test_fallback_description(resolved_title)
    test_config = build_primitive_test_config(
      group_class_name: group_class_name,
      resolved_title: resolved_title,
      resolved_description: resolved_description,
      test_id: "#{group_id}_#{build_id(test_type_id)}",
      high_order_group_file_name: high_order_group_file_name,
      group_file_name: group_file_name
    )
    apply_primitive_test_type_config!(test_config, test, test_type_id, resolved_title, resolved_description)
    PrimitiveTest.new(test_config).generate
  end
  # rubocop:enable Metrics/MethodLength

  def validate_primitive_test_type!(test_type_id)
    return if test_type_id == :bundle_valid
    return if TestConfigRegistry.registered?(test_type_id)

    raise "Unknown test type id: #{test_type_id.inspect}. Add it to TestConfigRegistry."
  end

  def resolve_primitive_test_labels(test, test_type_id)
    title = test[:title]
    description = test[:description]
    return [title, description] if test_type_id == :bundle_valid

    registry_config = TestConfigRegistry.config_for(test_type_id, @metadata)
    [title || registry_config[:title], description || registry_config[:description]]
  end

  def ensure_bundle_valid_has_title!(test_type_id, resolved_title)
    return unless test_type_id == :bundle_valid && resolved_title.nil?

    raise 'Bundle validation test requires bundle_validation_title in high-order config.'
  end

  def primitive_test_fallback_description(resolved_title)
    "Verifies that the resource meets the requirement: #{resolved_title}"
  end

  def build_primitive_test_config(opts)
    test_id = opts.fetch(:test_id)
    {
      class_name: "#{opts.fetch(:group_class_name)}#{build_class_name(opts.fetch(:resolved_title))}",
      title: opts.fetch(:resolved_title),
      description: opts.fetch(:resolved_description),
      id: test_id,
      output_file_path: versioned_path(
        opts.fetch(:high_order_group_file_name), opts.fetch(:group_file_name), filename: "#{test_id}.rb"
      )
    }
  end

  def apply_primitive_test_type_config!(test_config, test, test_type_id, resolved_title, resolved_description)
    if test_type_id == :bundle_valid
      test_config[:base_class_name] = test[:base_class_name]
      test_config[:imports] = test[:imports]
      test_config[:ignore_commands] = test[:ignore_commands]
    elsif TestConfigRegistry.registered?(test_type_id)
      test_config.merge!(TestConfigRegistry.config_for(test_type_id, @metadata))
      test_config[:title] = resolved_title
      test_config[:description] = resolved_description
    end
  end

  def generate_high_order_group(high_order_group, suite_class_name, suite_id)
    ids = high_order_group_ids(high_order_group, suite_id)
    high_order_class_name = "#{suite_class_name}#{build_class_name(high_order_group[:name])}"
    generic_bundle_groups = high_order_group[:groups].map do |generic_bundle_group|
      generate_primitive_group(generic_bundle_group, high_order_class_name, ids[:group_id], ids[:file_base])
    end
    config = high_order_group_config(high_order_group, high_order_class_name, ids, generic_bundle_groups)
    HighOrderGroup.new(config).generate
  end

  def high_order_group_ids(high_order_group, suite_id)
    file_base = build_id(high_order_group[:name]).to_s
    { group_id: :"#{suite_id}_#{build_id(high_order_group[:name])}", file_base: file_base }
  end

  def high_order_group_config(high_order_group, high_order_class_name, ids, generic_bundle_groups)
    path = ids.fetch(:file_base)
    # Path for require_relative must be relative to the high-order group file's directory
    config = {
      class_name: high_order_class_name,
      title: high_order_group[:name],
      description: high_order_group[:description] || group_description(high_order_group[:name]),
      id: ids.fetch(:group_id),
      groups: high_order_groups_with_relative_paths(generic_bundle_groups),
      output_file_path: versioned_path(path, filename: "#{path}.rb")
    }
    merge_optional_high_order_flags!(config, high_order_group)
  end

  def merge_optional_high_order_flags!(config, high_order_group)
    config[:optional] = high_order_group[:optional] if high_order_group.key?(:optional)
    config[:run_as_group] = high_order_group[:run_as_group] if high_order_group.key?(:run_as_group)
    config
  end

  def high_order_groups_with_relative_paths(generic_bundle_groups)
    generic_bundle_groups.map { |g| g.merge(path: g[:path].split('/').last) }
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
      description: suite_primitive_description,
      id: suite_id,
      groups: high_order_groups,
      output_file_path: versioned_path("#{ig_suite_version}_suite.rb")
    }
  end

  def suite_primitive_description
    'Validates AU PS (Australian Primary Care and Shared Health) bundles, compositions, sections, and ' \
      "server CapabilityStatement support for the #{@suite_version} implementation guide."
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
# rubocop:enable Metrics/ClassLength
