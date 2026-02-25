# frozen_string_literal: true

require_relative 'test_file_generator'

class Generator
  # Holds data for a section group.
  #
  # @attr_reader [Hash] group_data The data representing the section group.
  class SectionGroupData
    attr_reader :group_data

    # Initializes a new SectionGroupData.
    #
    # @param group_data [Hash] Metadata about the section group.
    def initialize(group_data)
      @group_data = group_data
    end
  end

  # Holds and manages test data for validating a section.
  #
  # @attr_reader [Hash] section_data The hash containing section data.
  class SectionTestData
    attr_reader :section_data

    # Initializes a new SectionTestData.
    #
    # @param section_data [Hash] Hash with keys:
    #   :short, :definition, :min, :max, :required, :mustSupport, :code, :entries
    def initialize(section_data)
      @short = section_data[:short]
      @definition = section_data[:definition]
      @min = section_data[:min]
      @max = section_data[:max]
      @required = section_data[:required]
      @must_support = section_data[:mustSupport]
      @code = section_data[:code]
      @entries = section_data[:entries]
    end

    # Generates a section-specific validation test file using the TestFileGenerator.
    #
    # @return [void]
    def generate
      test_file_generator = TestFileGenerator.new(
        template_file_path: 'au_ps_specific_section_validation_test.rb.erb',
        output_file_path: "#{test_id}.rb",
        attributes: build_attributes
      )
      test_file_generator.generate
      test_file_generator.test_file_summary
    end

    private

    # Builds the attributes hash passed to the test file template.
    #
    # @return [Hash] Hash of template attributes for file generation.
    def build_attributes
      {
        test_class_name: "AUPSSections#{humanized_name.gsub(' ', '')}Validation",
        section_name: humanized_name,
        test_id: test_id,
        optional: @min.zero?,
        section_id: @id
      }
    end

    # Returns a human-friendly section name for use in output and test classes.
    #
    # @return [String] Humanized section name with generic phrases stripped.
    def humanized_name
      @short.gsub('Patient Summary', '').gsub('Section', '').strip
    end

    # Returns a short, underscored name for test ID components.
    #
    # @return [String] Custom section ID.
    def test_id_custom
      @short.gsub('Patient Summary', '').gsub('Section', '').strip.gsub(' ', '_').downcase
    end

    # Returns the full test ID for the file name and references.
    #
    # @return [String] Full test ID.
    def test_id
      "au_ps_sections_#{test_id_custom}_validation"
    end
  end

  # Generates a validation group and corresponding test entities
  # for AU Patient Summary Composition sections.
  class SectionsValidationGroupGenerator
    # Initializes the group generator with metadata.
    #
    # @param metadata [#composition_sections] Object holding the composition_sections array.
    def initialize(metadata)
      @metadata = metadata
      @test_entities = []
    end

    # Generates the group and its test entity files.
    #
    # @return [void]
    def generate
      generate_test_entities
      generate_group
    end

    private

    # Stub for generating the overall sections validation group.
    #
    # @return [void]
    def generate_group
      TestFileGenerator.new(
        template_file_path: 'generic_group.rb.erb',
        output_file_path: 'au_ps_sections_validation_group.rb',
        attributes: build_group_attributes
      ).generate
    end

    def build_group_attributes
      {
        group_class_name: 'AUPSSectionsValidationGroup',
        group_title: 'AU PS Sections Validation',
        group_description: 'Verify that an AU PS Sections are valid.',
        group_id: 'au_ps_sections_validation_group',
        tests: @test_entities
      }
    end

    # Iterates all sections and generates their validation test files.
    #
    # @return [void]
    def generate_test_entities
      @metadata.composition_sections.each do |section|
        @test_entities << SectionTestData.new(section).generate
      end
    end
  end
end
