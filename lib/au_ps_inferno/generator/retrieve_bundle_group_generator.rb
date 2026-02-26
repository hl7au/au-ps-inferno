# frozen_string_literal: true

require_relative 'test_file_generator'

class Generator
  # Generates the au_ps_retrieve_bundle_group and its test files for a given version.
  # Uses the 0.5.0-preview structure: one valid-bundle test (RetrieveBundleTestClass) plus
  # six BasicTest tests (must-support, composition sections).
  class RetrieveBundleGroupGenerator
    GROUP_NAME = 'au_ps_retrieve_bundle_group'

    RETRIEVE_BUNDLE_TESTS = [
      {
        file_base: 'au_ps_retrieve_valid_bundle',
        class_base: 'AUPSRetrieveValidBundle',
        id_base: 'au_ps_retrieve_valid_bundle',
        title: 'Server provides valid requested AU PS Bundle',
        description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and ' \
                     'verify response is valid AU PS Bundle',
        base_class_require: '../../utils/retrieve_bundle_test_class',
        base_class_name: 'RetrieveBundleTestClass',
        description_comment: 'The Bundle resource is valid against the AU PS Bundle profile',
        run_code: nil
      },
      {
        file_base: 'au_ps_retrieve_bundle_has_must_support_elements',
        class_base: 'AUPSRetrieveBundleHasMUSTSUPPORTElements',
        id_base: 'au_ps_retrieve_bundle_has_must_support_elements',
        title: 'Bundle has mandatory must-support elements',
        description: 'Checks that the Bundle resource contains mandatory must-support elements (identifier, ' \
                     'type, timestamp) and that all entries have a fullUrl. Also provides information about the ' \
                     'resource types included in the Bundle.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The Must Support elements populated in the Bundle resource.',
        run_code: 'bundle_mandatory_ms_elements_info'
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_must_support_elements',
        class_base: 'AUPSRetrieveBundleCompositionMUSTSUPPORTElements',
        id_base: 'au_ps_retrieve_bundle_composition_must_support_elements',
        title: 'Composition has must-support elements',
        description: 'Checks that the Composition resource contains mandatory must-support elements ' \
                     '(status, type, subject.reference, date, author, title, section.title, section.text) and provides ' \
                     'information about optional must-support elements (text, identifier, attester, custodian, event).',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The Must Support elements populated in the Composition resource.',
        run_code: 'composition_mandatory_ms_elements_info'
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_mandatory_sections',
        class_base: 'AUPSRetrieveBundleCompositionMandatorySection',
        id_base: 'au_ps_retrieve_bundle_composition_mandatory_sections',
        title: 'Composition contains mandatory sections with entry references',
        description: 'Displays information about mandatory sections (Allergies and Intolerances, ' \
                     'Medication Summary, Problem List) in the Composition resource, including the entry references ' \
                     'within each section.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The mandatory sections populated in the Composition resource.',
        run_code: 'read_composition_mandatory_sections_info'
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_recommended_sections',
        class_base: 'AUPSRetrieveBundleCompositionRecommendedSection',
        id_base: 'au_ps_retrieve_bundle_composition_recommended_sections',
        title: 'Composition contains recommended sections with entry references',
        description: 'Displays information about recommended sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The recommended sections populated in the Composition resource.',
        run_code: 'read_composition_recommended_sections_info'
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_optional_sections',
        class_base: 'AUPSRetrieveBundleCompositionOptionalSection',
        id_base: 'au_ps_retrieve_bundle_composition_optional_sections',
        title: 'Composition contains optional sections with entry references',
        description: 'Displays information about optional sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The optional sections populated in the Composition resource.',
        run_code: 'read_composition_optional_sections_info'
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_other_sections',
        class_base: 'AUPSRetrieveBundleCompositionOtherSection',
        id_base: 'au_ps_retrieve_bundle_composition_other_sections',
        title: 'Composition contains other sections with entry references',
        description: 'Displays information about other sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'AU PS Composition Other Sections',
        run_code: 'check_other_sections'
      }
    ].freeze

    def initialize(version_suffix = '', suite_version = '')
      @version_suffix = version_suffix.to_s
      @suite_version = suite_version.to_s
      @output_base = build_output_base
      @test_entities = []
    end

    def generate
      generate_test_entities
      generate_group
    end

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
      base = 'AUPSRetrieveBundleGroup'
      @version_suffix.empty? ? base : "#{base}#{@version_suffix}"
    end

    def generate_group
      config = {
        template_file_path: 'retrieve_bundle_group.rb.erb',
        output_file_path: 'au_ps_retrieve_bundle_group.rb',
        attributes: {
          group_class_name: versioned_group_class,
          group_title: 'Retrieve AU PS Bundle validation tests',
          group_description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and ' \
                             'verify response is valid AU PS Bundle',
          group_id: versioned_group_id,
          tests: @test_entities
        }
      }
      config[:output_base] = @output_base if @output_base
      TestFileGenerator.new(config).generate
    end

    def generate_test_entities
      RETRIEVE_BUNDLE_TESTS.each do |spec|
        file_name = "#{spec[:file_base]}.rb"
        test_class_name = @version_suffix.empty? ? spec[:class_base] : "#{spec[:class_base]}#{@version_suffix}"
        test_id = @version_suffix.empty? ? spec[:id_base] : "#{spec[:id_base]}_#{@version_suffix}"

        attributes = {
          file_name: file_name,
          test_class_name: test_class_name,
          test_id: test_id,
          test_title: spec[:title],
          test_description: spec[:description],
          base_class_require: spec[:base_class_require],
          base_class_name: spec[:base_class_name],
          description_comment: spec[:description_comment],
          run_code: spec[:run_code]
        }

        config = {
          template_file_path: 'retrieve_bundle_test.rb.erb',
          output_file_path: file_name,
          attributes: attributes
        }
        config[:output_base] = @output_base if @output_base
        TestFileGenerator.new(config).generate
        @test_entities << { file_name: file_name, test_id: test_id }
      end
    end

    def build_output_base
      return nil if @suite_version.empty?

      File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version, GROUP_NAME))
    end
  end
end
