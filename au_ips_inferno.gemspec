# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'au_ips_inferno'
  spec.version       = '0.0.1'
  spec.authors       = ['Ilya Beda', 'Pavel Rozhkov']
  spec.email         = ['ilya@beda.software', 'pavel.r@beda.software']
  spec.date          = Time.now.utc.strftime('%Y-%m-%d')
  spec.summary       = 'AU IPS Inferno Test Kit'
  spec.description   = 'AU IPS Inferno Test Kit'
  spec.homepage      = 'https://github.com/hl7au/au-ps-inferno'
  spec.license       = 'Apache-2.0'
  spec.add_runtime_dependency 'inferno_core', '~> 0.6.2'
  spec.add_development_dependency 'database_cleaner-sequel', '~> 1.8'
  spec.add_development_dependency 'factory_bot', '~> 6.1'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'webmock', '~> 3.11'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.6')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.files = [
    Dir['lib/**/*.rb'],
    Dir['lib/**/*.json'],
    'LICENSE'
  ].flatten

  spec.require_paths = ['lib']
end
