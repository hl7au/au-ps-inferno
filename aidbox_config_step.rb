# frozen_string_literal: true

require 'net/http'
require 'json'
require 'securerandom'

# Single HTTP step (POST with JSON or multipart body) against an Aidbox base URL.
class AidboxConfigStep
  def initialize(base_url, path, method, body, headers)
    @base_url = base_url
    @path = path
    @method = method
    @body = body
    @headers = headers
  end

  def build_multipart_body(file_path, form_field, boundary)
    filename = File.basename(file_path)
    content = File.binread(file_path)
    [
      "--#{boundary}\r\n",
      "Content-Disposition: form-data; name=\"#{form_field}\"; filename=\"#{filename}\"\r\n",
      "Content-Type: application/octet-stream\r\n\r\n",
      content,
      "\r\n--#{boundary}--\r\n"
    ].join
  end

  def post
    uri = URI.parse(@base_url + @path)
    request_headers = @headers.dup
    body, multipart = build_post_payload(request_headers)
    request = Net::HTTP::Post.new(uri, request_headers)
    request.body = body
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      log_post_attempt(uri, multipart, request_headers, body)
      response = http.request(request)
      puts response.body
    end
  end

  def execute
    case @method
    when 'POST'
      post
    else
      raise "Method #{@method} not supported"
    end
  end

  private

  def build_post_payload(request_headers)
    return multipart_post_payload(request_headers) if multipart_request?

    hash_or_string_post_payload
  end

  def multipart_request?
    @body.is_a?(Hash) && @body[:__multipart_file]
  end

  def multipart_post_payload(request_headers)
    file_path = @body[:__multipart_file]
    form_field = @body[:__form_field] || 'file'
    boundary = "----RubyFormBoundary#{SecureRandom.hex(16)}"
    request_headers['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
    [build_multipart_body(file_path, form_field, boundary), true]
  end

  def hash_or_string_post_payload
    body_hash = @body.is_a?(Hash)
    return ['', false] if body_hash && @body.empty?
    return [@body.to_json, false] if body_hash

    [@body.to_s, false]
  end

  def log_post_attempt(uri, multipart, request_headers, body)
    multipart_note = multipart ? ' (multipart/form-data)' : ''
    puts "Attempting to POST #{uri}#{multipart_note} with headers #{request_headers.to_json}"
    puts "(body size: #{body.bytesize} bytes)" if multipart
  end
end
