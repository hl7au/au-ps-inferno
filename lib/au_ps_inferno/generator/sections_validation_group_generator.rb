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
    # @param version_suffix [String] Optional version suffix (e.g. "100preview")
    def initialize(section_data, metadata, version_suffix = '')
      @version_suffix = version_suffix.to_s
      @metadata = metadata
      assign_section_attributes(section_data)
    end

    def assign_section_attributes(section_data)
      @id = section_data[:id]
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
    # @param output_base [String, nil] Optional base path for output
    # @return [void]
    def generate(output_base = nil)
      config = {
        template_file_path: 'au_ps_specific_section_validation_test.rb.erb',
        output_file_path: "#{test_id}.rb",
        attributes: build_attributes
      }
      config[:output_base] = output_base if output_base
      test_file_generator = TestFileGenerator.new(config)
      test_file_generator.generate
      test_file_generator.test_file_summary
    end

    private

    # Builds the attributes hash passed to the test file template.
    #
    # @return [Hash] Hash of template attributes for file generation.
    def build_attributes
      {
        test_class_name: versioned_test_class_name,
        section_name: humanized_name,
        test_id: test_id,
        optional: @min.zero?,
        section_id: @metadata.normalize_section_data(@id)
      }
    end

    def versioned_test_class_name
      base = "AUPSSections#{humanized_name.gsub(' ', '')}Validation"
      @version_suffix.empty? ? base : "#{base}#{@version_suffix}"
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
      base = "au_ps_sections_#{test_id_custom}_validation"
      @version_suffix.empty? ? base : "#{base}_#{@version_suffix}"
    end
  end

  # Generates a validation group and corresponding test entities
  # for AU Patient Summary Composition sections.
  class SectionsValidationGroupGenerator
    GROUP_NAME = 'au_ps_sections_validation_group'

    # Initializes the group generator with metadata.
    #
    # @param metadata [#composition_sections] Object holding the composition_sections array.
    # @param version_suffix [String] Optional version suffix for class names and ids (e.g. "100preview")
    # @param suite_version [String] Suite version for output path (e.g. "0.5.0-preview").
    #   Output is written to lib/au_ps_inferno/{suite_version}/{group_name}/.
    def initialize(metadata, version_suffix = '', suite_version = '')
      @metadata = metadata
      @version_suffix = version_suffix.to_s
      @suite_version = suite_version.to_s
      @test_entities = []
      @output_base = build_output_base
    end

    # Generates the group and its test entity files.
    #
    # @return [void]
    def generate
      generate_test_entities
      generate_group
    end

    # Returns a hash describing this group for suite generation (require path and group_id).
    #
    # @return [Hash] with :file_path (relative to suite dir) and :attributes => { :group_id => String }
    def suite_group_info
      group_id = versioned_group_id
      {
        file_path: "#{GROUP_NAME}/#{GROUP_NAME}.rb",
        attributes: { group_id: group_id }
      }
    end

    def versioned_group_id
      @version_suffix.empty? ? GROUP_NAME : "#{GROUP_NAME}_#{@version_suffix}"
    end

    private

    # Stub for generating the overall sections validation group.
    #
    # @return [void]
    def generate_group
      config = {
        template_file_path: 'generic_group.rb.erb',
        output_file_path: 'au_ps_sections_validation_group.rb',
        attributes: build_group_attributes
      }
      config[:output_base] = @output_base if @output_base
      TestFileGenerator.new(config).generate
    end

    def build_group_attributes
      {
        group_class_name: versioned_group_class,
        group_title: 'AU PS Sections Validation',
        group_description: 'Verify that an AU PS Sections are valid.',
        group_id: versioned_group_id,
        tests: @test_entities
      }
    end

    def versioned_group_class
      base = 'AUPSSectionsValidationGroup'
      @version_suffix.empty? ? base : "#{base}#{@version_suffix}"
    end

    # Iterates all sections and generates their validation test files.
    #
    # @return [void]
    def generate_test_entities
      @metadata.composition_sections.each do |section|
        @test_entities << SectionTestData.new(section, @metadata, @version_suffix).generate(@output_base)
      end
    end

    def build_output_base
      return nil if @suite_version.empty?

      # Path relative to project root when running from Rake
      File.expand_path(File.join('lib', 'au_ps_inferno', @suite_version, GROUP_NAME))
    end
  end
end
