# frozen_string_literal: true

require_relative 'ig_resources_extractor'
require_relative 'metadata_manager'

# A class to generate test suites for the AU PS and IPS implementation guides
class Generator
  def initialize(ig_path)
    resources_manager = IGResourcesExtractor.new(ig_path)
    @ig_path = ig_path
    @resources_manager = resources_manager
    @metadata = MetadataManager.new(resources_manager.ig_resources)
  end

  def generate
    @resources_manager.extract
    @metadata.save_to_file('metadata.yaml')
  end
end
