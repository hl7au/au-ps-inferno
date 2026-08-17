#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fhir_packages_manager'

ROOT_DIR = File.expand_path('..', __dir__)
DEFAULT_PACKAGE_NAME = 'hl7.fhir.au.ps'
DEFAULT_DESTINATION = File.join(ROOT_DIR, 'lib', 'au_ps_inferno', 'igs')
DEFAULT_REGISTRIES = ['https://packages.fhir.org', 'https://packages.simplifier.net'].freeze

def fetch_latest_ig_package(name: DEFAULT_PACKAGE_NAME, destination: DEFAULT_DESTINATION,
                            registries: DEFAULT_REGISTRIES)
  manager = FhirPackagesManager::Manager.new(registries: registries, destination: destination)
  manager.fetch(name)
end

if $PROGRAM_NAME == __FILE__
  result = fetch_latest_ig_package
  case result.status
  when :downloaded
    puts "Downloaded #{result.package} from #{result.registry} to #{result.path}"
  when :not_found
    warn "#{DEFAULT_PACKAGE_NAME} not found on any of: #{DEFAULT_REGISTRIES.join(', ')}"
    exit 1
  when :error
    warn "Failed to fetch #{DEFAULT_PACKAGE_NAME}: #{result.error}"
    exit 1
  end
end
