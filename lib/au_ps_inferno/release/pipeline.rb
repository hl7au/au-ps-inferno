# frozen_string_literal: true

require_relative 'package_source'
require_relative 'suite_version_builder'
require_relative 'main_file_writer'

module Release
  # Orchestrates the full release pipeline
  class Pipeline
    def initialize(package_source: PackageSource.new, main_file_writer: MainFileWriter.new)
      @package_source = package_source
      @main_file_writer = main_file_writer
    end

    def fetch_igs
      @package_source.sync_all
    end

    def generate_all(downloads: nil)
      (downloads || fetch_igs).map do |download|
        SuiteVersionBuilder.new(version: download.version, package_archive_path: download.path).build!
      end
    end

    def attach!
      @main_file_writer.write!
    end

    def run!
      generate_all
      attach!
    end
  end
end
