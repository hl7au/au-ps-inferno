# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.6'

gemspec

group :development, :test do
  gem 'debug'
end

# gem 'inferno_ps_suite_generator', path: '../inferno_ps_suite_generator'
gem 'inferno_ps_suite_generator', git: 'https://github.com/beda-software/inferno_ps_suite_generator',
                                  ref: 'ed160bea44564441c4ce95fae172241c075212eb'
gem 'pg', '~> 1.5'
gem 'rubocop', '~> 1.71.2'
