# frozen_string_literal: true

require 'base64'
require_relative 'aidbox_config_step'

# Queues Aidbox HTTP configuration steps (JSON POST or file upload) and runs them in order.
class AidboxConfig
  def initialize(base_url)
    @base_url = base_url
    @steps = []
  end

  def add_step(path, method, body, headers)
    @steps << AidboxConfigStep.new(@base_url, path, method, body, headers)
  end

  # Add a step that POSTs multipart/form-data (e.g. for /$upload-fhir-npm-packages).
  # file_path: path to the archive file; form_field: name of the file input (default "file").
  def add_upload_step(path, file_path, headers = {}, form_field: 'file')
    body = { __multipart_file: file_path, __form_field: form_field }
    @steps << AidboxConfigStep.new(@base_url, path, 'POST', body, headers)
  end

  def execute_all
    @steps.each(&:execute)
  end
end

login = ENV.fetch('AIDBOX_CLIENT_ID', 'root')
password = ENV.fetch('AIDBOX_CLIENT_SECRET', 'secret')
authorization = "Basic #{Base64.strict_encode64("#{login}:#{password}")}"
base_url = ENV.fetch('AIDBOX_BASE_URL', 'http://localhost:3500')
json_headers = { 'Content-Type' => 'application/json', 'Authorization' => authorization }

configurer = AidboxConfig.new(base_url)
configurer.add_step('/fhir/ValueSet', 'POST',
                    File.read('./resources/ValueSet-australian-indigenous-status-1.json'),
                    json_headers)
configurer.add_step(
  '/fhir/ValueSet', 'POST',
  File.read('./resources/ValueSet-australian-immunisation-register-vaccine-1.json'),
  json_headers
)
configurer.add_step('/fhir/ValueSet', 'POST',
                    File.read('./resources/ValueSet-australian-medication-1.json'),
                    json_headers)
configurer.add_step('/fhir/ValueSet', 'POST', File.read('./resources/ValueSet-amt-vaccine-1.json'),
                    json_headers)
configurer.add_step(
  '/fhir/CodeSystem', 'POST',
  File.read('./resources/CodeSystem-australian-indigenous-status-1.json'),
  json_headers
)
configurer.add_step('/fhir/ValueSet', 'POST', File.read('./resources/ValueSet-ihi-status-1.json'),
                    json_headers)
configurer.add_step('/fhir/ValueSet', 'POST',
                    File.read('./resources/ValueSet-ihi-record-status-1.json'),
                    json_headers)
configurer.execute_all
