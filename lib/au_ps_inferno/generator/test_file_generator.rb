# frozen_string_literal: true

require 'erb'
require 'fileutils'

class Generator
  # TestFile generator. Use config to generate the test file.
  # Config is: template_file_path, output_file_path, a hash with any attributes to use in the template
  # All template files should be in the templates folder.
  class TestFileGenerator
    # @param config [Hash] configuration hash
    # @option config [String] :template_file_path Relative path to the ERB template file
    # @option config [String] :output_file_path Relative path to output the generated test file
    # @option config [Hash] :attributes Hash of variables made available to the ERB template
    def initialize(config)
      @template_file_path = config[:template_file_path]
      @output_file_path = config[:output_file_path]
      @attributes = config[:attributes]
    end

    # Generates the test file by rendering the template using the provided attributes.
    # The result is saved to the output_file_path (under the 'tests' directory).
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
        attribtes: @attributes
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

    # Returns the absolute path to the output test file,
    # which will be placed in the 'tests' directory relative to this file.
    #
    # @return [String] Absolute path to the output test file
    def output_file_path
      File.join(File.dirname(__FILE__), 'tests', @output_file_path)
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
