# frozen_string_literal: true

require 'json'

# Serialises a suite's runnable tree (ids, titles, descriptions, inputs, outputs, routes and
# validator configuration) into plain JSON-compatible data, so a spec can compare a suite
# against a recorded fixture and prove a refactor left it unchanged.
module SuiteTree
  module_function

  def dump_suite(suite)
    stringify(
      'id' => suite.id.to_s,
      'title' => suite.title,
      'description' => suite.description,
      'validators' => validators(suite),
      'version' => suite.version,
      'links' => suite.links,
      'routes' => routes(suite),
      'children' => suite.children.map { |child| dump_runnable(child) }
    )
  end

  def dump_runnable(runnable)
    node = runnable_attributes(runnable)
    node['run_as_group'] = runnable.run_as_group? if runnable.respond_to?(:run_as_group?)
    node['children'] = runnable.children.map { |child| dump_runnable(child) } if runnable.respond_to?(:children)
    node
  end

  def runnable_attributes(runnable) # rubocop:disable Metrics/MethodLength
    {
      'id' => runnable.id.to_s,
      'database_id' => runnable.database_id.to_s,
      'class' => runnable.ancestors.find(&:name)&.name,
      'title' => runnable.title,
      'short_title' => runnable.short_title,
      'description' => runnable.description,
      'short_description' => runnable.short_description,
      'optional' => runnable.optional?,
      'inputs' => runnable.available_inputs.transform_values(&:to_hash),
      'outputs' => runnable.outputs.map(&:to_s)
    }
  end

  def routes(suite)
    Inferno.routes.select { |route| route[:suite] == suite }.map do |route|
      { 'method' => route[:method].to_s, 'path' => route[:path], 'handler' => route[:handler].name }
    end
  end

  def validators(suite)
    suite.fhir_validators.transform_values do |validators|
      validators.map do |validator|
        {
          'igs' => validator.igs,
          'context' => validator.validation_context.definition,
          'additional_validations' => validator.additional_validations.length,
          'exclude_message' => !validator.exclude_message.nil?
        }
      end
    end
  end

  def stringify(value)
    JSON.parse(JSON.generate(value))
  end
end
