# frozen_string_literal: true

require_relative 'bundle_decorator'

# A class to keep helper methods for section tests
class SectionTestClass
  attr_reader :name, :code

  def initialize(section_config, _bundle_resource)
    @section_config = section_config
    @code = section_config['code']
    @name = section_config['name']
  end

  def humanized_name
    "#{@name} (#{@code})"
  end
end
