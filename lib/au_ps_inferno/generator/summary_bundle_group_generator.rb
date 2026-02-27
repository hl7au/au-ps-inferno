# frozen_string_literal: true

require_relative 'summary_bundle_group_tests'
require_relative 'test_file_generator'

class Generator
  # Generates the au_ps_summary_bundle_group and its test files for a given version.
  #
  # One valid-bundle test (SummaryValidBundleClass) plus six BasicTest tests (must-support,
  # composition sections). Uses summary_bundle_group.rb.erb and retrieve_bundle_test.rb.erb.
  class SummaryBundleGroupGenerator
    GROUP_NAME = 'au_ps_summary_bundle_group'
    GROUP_TITLE = 'Generate AU PS using IPS $summary validation tests'
    GROUP_DESCRIPTION = 'Generate AU Patient Summary using IPS $summary operation and verify response is valid ' \
                        'AU PS Bundle'

    # @param version_suffix [String] Short version suffix (e.g. '100preview')
    # @param suite_version [String] Suite version folder (e.g. '1.0.0-preview')
    def initialize(metadata, version_suffix = '', suite_version = '')
      @version_suffix = version_suffix.to_s
      @suite_version = suite_version.to_s
      @output_base = build_output_base
      @metadata = metadata
      @test_entities = []
    end

    # Generates the group file and all test files under the version folder.
    # @return [void]
    def generate
      generate_test_entities
      generate_group
    end

    # Returns suite group info for inclusion in the suite template.
    # @return [Hash] { file_path:, attributes: { group_id: } }
    def suite_group_info
      {
        file_path: "#{GROUP_NAME}/#{GROUP_NAME}.rb",
        attributes: { group_id: versioned_group_id }
      }
    end

    private

    def versioned_group_id
      @version_suffix.empty? ? GROUP_NAME : "#{GROUP_NAME}_#{@version_suffix}"
    end

    def versioned_group_class
      base = 'AUPSSummaryBundleGroup'
      @version_suffix.empty? ? base : "#{base}#{@version_suffix}"
    end

    def generate_group
      config = {
        template_file_path: 'summary_bundle_group.rb.erb',
        output_file_path: 'au_ps_summary_bundle_group.rb',
        attributes: group_attributes
      }
      config[:output_base] = @output_base if @output_base
      TestFileGenerator.new(config).generate
    end

    def group_attributes
      {
        group_class_name: versioned_group_class,
        group_title: GROUP_TITLE,
        group_description: GROUP_DESCRIPTION,
        group_id: versioned_group_id,
        group_class_comment: 'Generate AU Patient Summary using IPS $summary operation and verify response is ' \
                             'valid AU PS Bundle',
        tests: @test_entities
      }
    end

    def generate_test_entities
      SummaryBundleGroupTests::TESTS.each do |spec|
        entity = generate_one_test(spec, @metadata)
        @test_entities << entity
      end
    end

    def generate_one_test(spec, metadata)
      file_name = "#{spec[:file_base]}.rb"
      test_id = versioned_test_id(spec[:id_base])
      config = test_file_config(spec, file_name, test_id, metadata)
      config[:output_base] = @output_base if @output_base
      TestFileGenerator.new(config).generate
      { file_name: file_name, test_id: test_id }
    end

    def versioned_test_id(id_base)
      @version_suffix.empty? ? id_base : "#{id_base}_#{@version_suffix}"
    end

    def versioned_test_class_name(class_base)
      @version_suffix.empty? ? class_base : "#{class_base}#{@version_suffix}"
    end

    def test_file_config(spec, file_name, test_id, metadata)
      {
        template_file_path: 'retrieve_bundle_test.rb.erb',
        output_file_path: file_name,
        attributes: test_file_attributes(spec, file_name, test_id, metadata)
      }
    end

    def test_file_attributes(spec, file_name, test_id, metadata)
      {
        file_name: file_name, test_id: test_id,
        test_class_name: versioned_test_class_name(spec[:class_base]),
        test_title: spec[:title], test_description: spec[:description],
        base_class_require: spec[:base_class_require],
        base_class_name: spec[:base_class_name],
        description_comment: spec[:description_comment],
        run_code: run_code(spec, metadata)
      }
    end

    def run_code(spec, metadata)
      case spec[:file_base]
      when 'au_ps_summary_bundle_composition_mandatory_sections'
        "read_composition_sections_info(#{metadata.required_sections_data_codes}, #{metadata.sections_codes_mapping})"
      when 'au_ps_summary_bundle_composition_recommended_sections'
        "read_composition_sections_info(#{metadata.recommended_sections_data_codes}, #{metadata.sections_codes_mapping})"
      when 'au_ps_summary_bundle_composition_optional_sections'
        "read_composition_sections_info(#{metadata.optional_sections_data_codes}, #{metadata.sections_codes_mapping})"
      when 'au_ps_summary_bundle_has_must_support_elements'
        'bundle_mandatory_ms_elements_info'
      when 'au_ps_summary_bundle_composition_must_support_elements'
        "composition_mandatory_ms_elements_info(#{metadata.optional_ms_elements}, #{metadata.mandatory_ms_elements}, #{metadata.optional_ms_sub_elements}, #{metadata.mandatory_ms_sub_elements}, #{metadata.mandatory_ms_slices}, #{metadata.optional_ms_slices})"
      when 'au_ps_summary_bundle_composition_other_sections'
        "check_other_sections(#{metadata.all_sections_data_codes}, #{metadata.sections_codes_mapping})"
      else
        spec[:run_code]
      end
    end

    def build_output_base
      return nil if @suite_version.empty?

      File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version, GROUP_NAME))
    end
  end
end
