#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'net/http'
require 'uri'

ROOT_DIR = File.expand_path('..', __dir__)
DEFAULT_INPUT = File.join(ROOT_DIR, 'additional_resources', 'deps_urls.txt')
DEFAULT_OUTPUT_DIR = File.join(ROOT_DIR, 'additional_resources')
MAX_REDIRECTS = 10

def read_canonical_urls(path)
  File.readlines(path, chomp: true)
      .map(&:strip)
      .reject { |line| line.empty? || line.start_with?('#') }
end

def http_get_with_redirects(url, limit: MAX_REDIRECTS, accept: '*/*')
  raise ArgumentError, 'Redirect limit exceeded' if limit <= 0

  uri = URI.parse(url)
  response = perform_http_get(uri, accept: accept)
  handle_http_response(uri, url, response, limit: limit, accept: accept)
end

def perform_http_get(uri, accept:)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = 'au-ps-inferno-structuredefinition-fetcher'
    request['Accept'] = accept
    http.request(request)
  end
end

def handle_http_response(uri, original_url, response, limit:, accept:)
  return [uri.to_s, response] if response.is_a?(Net::HTTPSuccess)

  if response.is_a?(Net::HTTPRedirection)
    return follow_redirect(uri, original_url, response, limit: limit, accept: accept)
  end

  raise "HTTP #{response.code} #{response.message} for #{original_url}"
end

def follow_redirect(uri, original_url, response, limit:, accept:)
  location = response['location'] || fallback_location_from_body(response.body, uri)
  raise "Redirect response without Location header for #{original_url}" unless location

  redirect_uri = URI.join(uri.to_s, location).to_s
  http_get_with_redirects(redirect_uri, limit: limit - 1, accept: accept)
end

def fallback_location_from_body(body, current_uri)
  return nil unless body

  hrefs = body.scan(/href="([^"]+)"/i).flatten
  return nil if hrefs.empty?

  relative = preferred_body_redirect(hrefs)
  return nil unless relative

  URI.join(current_uri.to_s, relative).to_s
rescue URI::InvalidURIError
  nil
end

def preferred_body_redirect(hrefs)
  hrefs.find { |href| html_redirect_candidate?(href) } ||
    hrefs.find { |href| href.end_with?('.json') } ||
    hrefs.first
end

def html_redirect_candidate?(href)
  href.end_with?('.html') && !href.end_with?('.profile.json.html')
end

def html_to_profile_json_url(html_url)
  return nil unless html_url.end_with?('.html')

  html_url.sub(/\.html\z/, '.profile.json')
end

def html_to_json_url(html_url)
  return nil unless html_url.end_with?('.html')

  html_url.sub(/\.html\z/, '.json')
end

def output_file_name(json_url)
  File.basename(URI.parse(json_url).path)
end

def ensure_valid_json!(raw, source_url)
  JSON.parse(raw)
rescue JSON::ParserError => e
  raise "Downloaded content is not valid JSON from #{source_url}: #{e.message}"
end

def existing_profile_urls(output_dir)
  urls = {}
  json_files = Dir.glob(File.join(output_dir, '*.json'))

  json_files.each do |path|
    url = read_profile_url(path)
    next unless url

    urls[url] = path
  end

  urls
end

def read_profile_url(path)
  parsed = JSON.parse(File.read(path))
  url = parsed['url']
  return nil unless url.is_a?(String)

  stripped = url.strip
  return nil if stripped.empty?

  stripped
rescue StandardError
  # Ignore unreadable/non-JSON files while building the cache.
  nil
end

def json_candidates_from_final_url(final_url)
  return [final_url] if final_url.end_with?('.profile.json', '.json')
  return [] unless final_url.end_with?('.html')

  [html_to_profile_json_url(final_url), html_to_json_url(final_url)].compact.uniq
end

def fetch_json_response(final_url, final_response, candidate)
  return final_response if final_url == candidate

  _, fetched = http_get_with_redirects(candidate, accept: 'application/json')
  fetched
end

def resolve_valid_json_candidate(canonical_url, final_url, final_response, json_candidates)
  last_error = nil

  json_candidates.each do |candidate|
    response = fetch_json_response(final_url, final_response, candidate)
    ensure_valid_json!(response.body, candidate)
    return [candidate, response]
  rescue StandardError => e
    last_error = e
  end

  raise(last_error || "Unable to fetch valid JSON for #{canonical_url}")
end

def fetch_definition_json(canonical_url)
  final_url, final_response = http_get_with_redirects(canonical_url, accept: 'text/html')
  json_candidates = json_candidates_from_final_url(final_url)
  raise "Final URL is neither HTML nor JSON: #{final_url}" if json_candidates.empty?

  json_url, json_response = resolve_valid_json_candidate(
    canonical_url,
    final_url,
    final_response,
    json_candidates
  )
  [final_url, json_url, json_response]
end

def save_json_response(output_dir, json_url, json_response)
  file_name = output_file_name(json_url)
  output_path = File.join(output_dir, file_name)
  File.write(output_path, json_response.body)
  output_path
end

def fetch_and_save_structure_definition(canonical_url, output_dir)
  final_url, json_url, json_response = fetch_definition_json(canonical_url)
  output_path = save_json_response(output_dir, json_url, json_response)

  {
    canonical_url: canonical_url,
    final_html_url: final_url,
    json_url: json_url,
    output_path: output_path
  }
end

def valid_input?(input_path)
  return true if File.file?(input_path)

  warn "Input file not found: #{input_path}"
  false
end

def load_canonical_urls(input_path)
  canonical_urls = read_canonical_urls(input_path)
  return canonical_urls unless canonical_urls.empty?

  warn "No canonical URLs found in #{input_path}"
  nil
end

def skip_existing_url?(existing_urls, canonical_url, skipped)
  return false unless existing_urls.key?(canonical_url)

  existing_path = existing_urls[canonical_url]
  skipped << { canonical_url: canonical_url, existing_path: existing_path }
  puts "SKIP: #{canonical_url} -> already exists in #{existing_path}"
  true
end

def process_canonical_url(canonical_url, output_dir, state)
  return if skip_existing_url?(state[:existing_urls], canonical_url, state[:skipped])

  result = fetch_and_save_structure_definition(canonical_url, output_dir)
  record_success(result, state)
rescue StandardError => e
  record_failure(canonical_url, e, state)
end

def record_success(result, state)
  state[:successes] << result
  puts "OK: #{result[:canonical_url]} -> #{result[:output_path]}"
  state[:existing_urls][result[:canonical_url]] = result[:output_path]
end

def record_failure(canonical_url, error, state)
  state[:failures] << { canonical_url: canonical_url, error: error.message }
  warn "ERROR: #{canonical_url} -> #{error.message}"
end

def print_summary(state)
  summary = "\nSummary: #{state[:successes].size} succeeded, " \
            "#{state[:skipped].size} skipped, #{state[:failures].size} failed"
  puts summary
end

def print_failures(failures)
  return if failures.empty?

  puts 'Failed URLs:'
  failures.each do |failure|
    puts "- #{failure[:canonical_url]}: #{failure[:error]}"
  end
end

def build_run_state(output_dir)
  {
    successes: [],
    failures: [],
    skipped: [],
    existing_urls: existing_profile_urls(output_dir)
  }
end

def process_canonical_urls(canonical_urls, output_dir, state)
  canonical_urls.each do |canonical_url|
    process_canonical_url(canonical_url, output_dir, state)
  end
end

def fetch_structure_definitions(input_path = DEFAULT_INPUT, output_dir = DEFAULT_OUTPUT_DIR)
  return 1 unless valid_input?(input_path)

  FileUtils.mkdir_p(output_dir)
  canonical_urls = load_canonical_urls(input_path)
  return 1 if canonical_urls.nil?

  state = build_run_state(output_dir)
  process_canonical_urls(canonical_urls, output_dir, state)

  print_summary(state)
  print_failures(state[:failures])
  return 1 if state[:failures].any?

  0
end

if $PROGRAM_NAME == __FILE__
  input_path = ARGV[0] || DEFAULT_INPUT
  output_dir = ARGV[1] || DEFAULT_OUTPUT_DIR
  exit(fetch_structure_definitions(input_path, output_dir))
end
