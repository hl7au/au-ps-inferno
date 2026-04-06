# frozen_string_literal: true

require 'active_support/core_ext/object/blank'

require_relative '../../lib/au_ps_inferno/utils/basic_test/resource_helpers_module'
require_relative '../../lib/au_ps_inferno/utils/basic_test/resolve_resource_type_module'

module AUPSTestKit
  # Minimal object for unit-testing {BasicTestResolveResourceTypeModule} without Inferno.
  class ResolveResourceTypeModuleHost
    include BasicTestResourceHelpersModule
    include BasicTestResolveResourceTypeModule

    attr_accessor :resolved_resource, :metadata_entries
    attr_reader :messages, :assertions

    def initialize
      @messages = []
      @assertions = []
      @metadata_entries = []
    end

    def add_message(level, msg)
      messages << [level, msg]
    end

    def assert(condition, msg = nil)
      assertions << [condition, msg]
      raise msg || 'Assertion failed' unless condition

      nil
    end

    def get_resource_by_container_type(_container_type)
      resolved_resource
    end

    def get_target_metadata_by_container_type(_container_type)
      metadata_entries
    end
  end
end
