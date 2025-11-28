# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/basic_test_class'

MANDATORY_MS_ELEMENTS = [
  {:expression => "$.status", :label => "status"},
  {:expression => "$.type", :label => "type"},
  {:expression => "$.subject.reference", :label => "subject.reference"},
  {:expression => "$.date", :label => "date"},
  {:expression => "$.author[0]", :label => "author"},
  {:expression => "$.title", :label => "title"}
].freeze

OPTIONAL_MS_ELEMENTS = [
  {:expression => "$.text", :label => "text"},
  {:expression => "$.identifier", :label => "identifier"},
  {:expression => "$.attester", :label => "asserter"},
  {:expression => "$.attester.mode", :label => "asserter.mode"},
  {:expression => "$.attester.time", :label => "asserter.time"},
  {:expression => "$.attester.party", :label => "asserter.party"},
  {:expression => "$.custodian", :label => "custodian"},
  {:expression => "$.event.code.coding.code", :label => "event"},
  {:expression => "$.event.code", :label => "event.code"},
  {:expression => "$.event.period", :label => "event.period"}].freeze

module AUPSTestKit
  class AUPSCompositionMUSTSUPPORTElements < BasicTest
    title TEXTS[:au_ps_composition_must_support_elements][:title]
    description TEXTS[:au_ps_composition_must_support_elements][:description]
    id :au_ps_composition_must_support_elements

    def composition_mandatory_ms_elements_info
      composition_resource = JsonPath.on(scratch[:ips_bundle_resource].to_json,
                                         '$.entry[?(@.resource.resourceType == "Composition")].resource').first

      mandatory_elements = MANDATORY_MS_ELEMENTS.map { |element| execute_statistics(composition_resource, element[:expression], element[:label]) }
      section_title = JsonPath.on(composition_resource, '$.section.*').length == JsonPath.on(composition_resource, '$.section.*.title').length
      section_text = JsonPath.on(composition_resource, '$.section.*').length == JsonPath.on(composition_resource, '$.section.*.text').length
      mandatory_elements.push("**section.title**: #{boolean_to_humanized_string(section_title)}")
      mandatory_elements.push("**section.text**: #{boolean_to_humanized_string(section_text)}")
      info "**List of Mandatory Must Support elements populated**:\n\n#{mandatory_elements.join("\n\n")}"

      optional_elements = OPTIONAL_MS_ELEMENTS.map do |element|
        execute_statistics(composition_resource, element[:expression], element[:label])
      end.join("\n\n")
      info "**List of Optional Must Support elements populated**:\n\n#{optional_elements}"
    end

    run do
      composition_mandatory_ms_elements_info
    end
  end
end
