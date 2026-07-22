#!/usr/bin/env ruby
# frozen_string_literal: true

# One-off/refresh download of the AU PS example bundles used by the
# spec/regression/ regression tests. Run manually and commit the result;
# it is not invoked as part of the test run itself.
#
#   ruby scripts/fetch_example_bundles.rb

require 'fileutils'
require 'net/http'
require 'uri'

ROOT_DIR = File.expand_path('..', __dir__)
OUTPUT_DIR = File.join(ROOT_DIR, 'spec', 'fixtures', 'bundles', 'examples')
MAX_REDIRECTS = 10

EXAMPLE_BUNDLES = [
  { name: 'aups-basicsummary',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-basicsummary.json' },
  { name: 'aups-gpvisit-retrieval',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-gpvisit-retrieval.json' },
  { name: 'aups-noknownx',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-noknownx.json' },
  { name: 'aups-patient-story',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-patient-story.json' },
  { name: 'aups-referral-endoconsult-autogen',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-referral-endoconsult-autogen.json' },
  { name: 'aups-referral-endoconsult-curated',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-referral-endoconsult-curated.json' },
  { name: 'aups-section-emptyreason',
    url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-section-emptyreason.json' }
].freeze

def perform_get(url)
  uri = URI.parse(url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.get(uri, { 'Accept' => 'application/fhir+json' })
  end
end

def http_get_with_redirects(url, limit: MAX_REDIRECTS)
  raise "Redirect limit exceeded for #{url}" if limit <= 0

  response = perform_get(url)

  case response
  when Net::HTTPSuccess
    response.body
  when Net::HTTPRedirection
    http_get_with_redirects(response['location'], limit: limit - 1)
  else
    raise "GET #{url} failed: #{response.code} #{response.message}"
  end
end

FileUtils.mkdir_p(OUTPUT_DIR)

EXAMPLE_BUNDLES.each do |bundle|
  puts "Fetching #{bundle[:name]} from #{bundle[:url]}"
  body = http_get_with_redirects(bundle[:url])
  File.write(File.join(OUTPUT_DIR, "#{bundle[:name]}.json"), body)
end

puts "Wrote #{EXAMPLE_BUNDLES.size} bundle fixtures to #{OUTPUT_DIR}"
