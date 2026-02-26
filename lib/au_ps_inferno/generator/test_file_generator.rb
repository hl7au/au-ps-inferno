# frozen_string_literal: true

require 'erb'
require 'fileutils'

class Generator
  # TestFile generator. Use config to generate the test file.
  # Config is: template_file_path, output_file_path, optional output_base, and attributes.
  # All template files should be in the templates folder.
  class TestFileGenerator
    # @param config [Hash] configuration hash
    # @option config [String] :template_file_path Relative path to the ERB template file
    # @option config [String] :output_file_path Relative path or filename for the generated file
    # @option config [String] :output_base Optional. When set, output is written to output_base/output_file_path
    #   (e.g. lib/au_ps_inferno/1.0.0-preview/au_ps_sections_validation_group). When omitted, uses generator/tests/.
    # @option config [Hash] :attributes Hash of variables made available to the ERB template
    def initialize(config)
      @template_file_path = config[:template_file_path]
      @output_file_path = config[:output_file_path]
      @output_base = config[:output_base]
      @attributes = config[:attributes]
    end

    # Generates the test file by rendering the template using the provided attributes.
    # The result is saved to output_base/output_file_path when output_base is set, else under generator/tests/.
    #
    # @return [void]
    def generate
      template = ERB.new(File.read(template_file_path))
      path = output_file_path
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, template.result(erb_binding))
      puts "Test file generated: #{path}"
    end

    def test_file_summary
      {
        file_path: output_file_path,
        attributes: @attributes
      }
    end

    private

    # Returns the absolute path to the ERB template file,
    # assumed to be in the 'templates' directory relative to this file.
    #
    # @return [String] Absolute path to the template file
    def template_file_path
      File.join(File.dirname(__FILE__), 'templates', @template_file_path)
    end

    # Returns the absolute path to the output test file.
    # When output_base is set, uses output_base/output_file_path; otherwise uses generator/tests/.
    #
    # @return [String] Absolute path to the output test file
    def output_file_path
      if @output_base
        File.join(File.expand_path(@output_base), @output_file_path)
      else
        File.join(File.dirname(__FILE__), 'tests', @output_file_path)
      end
    end

    # Prepares the binding for ERB by defining all provided attributes as methods
    # on an object, then returning that object's binding.
    #
    # @return [Binding] Binding context with attribute accessors defined
    def erb_binding
      context = Object.new
      @attributes.each do |key, value|
        context.define_singleton_method(key) { value }
      end
      context.instance_eval { binding }
    end
  end
end
