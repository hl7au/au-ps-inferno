# frozen_string_literal: true

# Shared pieces for default spec/spec_helper.rb (WebMock, Faraday, SimpleCov).
# Full Inferno + DB: require_relative 'spec_helper_inferno' from a spec file.

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter do |source_file|
      !source_file.filename.end_with?('/lib/au_ps_inferno/utils/validator_helpers.rb')
    end
  end
end

require 'faraday'
require 'webmock/rspec'
WebMock.disable_net_connect!
