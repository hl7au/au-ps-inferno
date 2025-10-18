module ValidatorHelpers
  def show_validator_version
    versions = get_or_create_validator_version
    if versions.nil?
      info 'Unable to fetch validator version'
      return
    end

    info "Using validator version #{versions.dig('validator_version') || 'Unknown'} and validator wrapper version #{versions.dig('validator_wrapper_version') || 'Unknown'}"
  end

  private

  def get_or_create_validator_version
    return cached_versions if version_cached?

    fetch_and_cache_versions
  end

  def fetch_and_cache_versions
    validator_url = ENV['FHIR_RESOURCE_VALIDATOR_URL']
    info "Fetching validator version from #{validator_url} URL"

    response_body = fetch_validator_version(validator_url)
    if response_body.nil?
      warning "Unable to fetch validator version from #{validator_url}"
      return
    end

    version_data = parse_response(response_body)
    if version_data.nil?
      warning "Unable to parse response from validator at #{validator_url}"
      return
    end
    unless %w[version wrapperVersion].all? { |key| version_data.keys.include?(key) }
      warning "Invalid response from validator at #{validator_url}: #{version_data}"
      return
    end

    cache_versions(version_data['version'], version_data['wrapperVersion'])

    build_version_hash(version_data['version'], version_data['wrapperVersion'])
  end

  def cache_versions(validator_version, validator_wrapper_version)
    scratch[:validator_version] = validator_version
    scratch[:validator_wrapper_version] = validator_wrapper_version
  end

  def version_cached?
    scratch[:validator_version] && scratch[:validator_wrapper_version]
  end

  def cached_versions
    build_version_hash(scratch[:validator_version], scratch[:validator_wrapper_version])
  end

  def fetch_validator_version(url)
    version_url = url + '/version'
    begin
      response = Faraday.get(version_url)
      response.body
    rescue Faraday::Error => e
      warning "Error connecting to validator at #{url}: #{e.message}"
      nil
    end
  end

  def parse_response(response_body)
    begin
      data = JSON.parse(response_body)
      data
    rescue JSON::ParserError => e
      warning "Error parsing response from validator: #{e.message}"
      nil
    end
  end

  def build_version_hash(validator_version, validator_wrapper_version)
    {
      "validator_version" => validator_version,
      "validator_wrapper_version" => validator_wrapper_version
    }
  end
end
