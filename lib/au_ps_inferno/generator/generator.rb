# frozen_string_literal: true

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'

# Generates test suites for the AU PS and IPS implementation guides.
#
# Extracts and persists resource metadata for use in test suite generation.
#
# @example
#   generator = Generator.new('/path/to/ig')
#   generator.generate
class Generator
  # Initializes a Generator with a given IG directory path.
  #
  # @param ig_path [String] Path to the Implementation Guide (IG) directory.
  def initialize(ig_path)
    resources_manager = IGResourcesExtractor.new(ig_path)
    @ig_path = ig_path
    @resources_manager = resources_manager
    @metadata = MetadataManager.new(resources_manager.ig_resources)
  end

  # Extract resources and save metadata to a YAML file.
  #
  # @return [void]
  def generate
    @resources_manager.extract
    @metadata.save_to_file('metadata.yaml')
  end
end
