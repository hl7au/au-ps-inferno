# frozen_string_literal: true

require 'erb'
require 'fileutils'

class Generator
  # High order group generator. Use config to generate the group file.
  # All template files should be in the templates folder.
  class HighOrderGroup
    attr_reader :class_name, :title, :description, :id, :groups, :output_file_path, :imports

    def initialize(config)
      @class_name = config[:class_name]
      @title = config[:title]
      @description = config[:description]
      @id = config[:id].to_sym
      @groups = config[:groups] || []
      @output_file_path = config[:output_file_path]
      @imports = config[:imports] || []
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
        path: @output_file_path,
        id: @id
      }
    end

    def template_file_path
      File.join(File.dirname(__FILE__), 'templates', 'high_order_group.rb.erb')
    end

    def erb_binding
      binding
    end
  end
end
