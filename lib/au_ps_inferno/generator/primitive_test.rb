# frozen_string_literal: true

require 'erb'
require 'fileutils'

class Generator
  # Primitive test generator. Use config to generate the test file.
  # Config is: template_file_path, output_file_path, optional output_base, and attributes.
  # All template files should be in the templates folder.
  class PrimitiveTest
    attr_reader :class_name, :base_class_name, :title, :description, :id, :commands, :output_file_path, :imports,
                :ignore_commands, :optional

    def initialize(config)
      @class_name = config[:class_name]
      @base_class_name = config[:base_class_name] || 'BasicTest'
      @title = config[:title]
      @description = config[:description]
      @id = config[:id].to_sym
      @commands = config[:commands] || []
      @output_file_path = config[:output_file_path]
      @imports = config[:imports] || []
      @ignore_commands = config[:ignore_commands] || false
      @optional = config[:optional] || false
    end

    def generate
      template = ERB.new(File.read(template_file_path))
      path = @output_file_path
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, template.result(erb_binding))

      result_information
    end

    private

    def result_information
      {
        path: @output_file_path.split('.rb').first.split('/').last(2).join('/'),
        id: @id
      }
    end

    def template_file_path
      File.join(File.dirname(__FILE__), 'templates', 'test_primitive.rb.erb')
    end

    def erb_binding
      binding
    end
  end
end
