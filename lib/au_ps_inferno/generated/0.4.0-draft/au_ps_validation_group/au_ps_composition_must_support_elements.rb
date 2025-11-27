# frozen_string_literal: true

require 'jsonpath'

module AUPSTestKit
  class AUPSCompositionMUSTSUPPORTElements < Inferno::Test
    title 'Composition has must-support elements'
    description 'Checks that the Composition resource contains mandatory must-support elements (status, type, subject.reference, date, author, title, section.title, section.text) and provides information about optional must-support elements (text, identifier, attester, custodian, event).'
    id :au_ps_composition_must_support_elements

    def show_message(message, state_value)
      if state_value
        info message
      else
        warning message
      end
    end

    def composition_mandatory_ms_elements_info
      data_for_testing = scratch[:ips_bundle_resource].to_json
      composition_resource = JsonPath.on(data_for_testing, '$.entry[?(@.resource.resourceType == "Composition")].resource').first

      status = JsonPath.on(composition_resource, '$.status').first.present?
      type = JsonPath.on(composition_resource, '$.type').first.present?
      subject_reference = JsonPath.on(composition_resource, '$.subject.reference').first.present?
      date = JsonPath.on(composition_resource, '$.date').first.present?
      author = JsonPath.on(composition_resource, '$.author[0]').first.present?
      title = JsonPath.on(composition_resource, '$.title').first.present?
      section_title = JsonPath.on(composition_resource, '$.section.*').length == JsonPath.on(composition_resource, '$.section.*.title').length
      section_text = JsonPath.on(composition_resource, '$.section.*').length == JsonPath.on(composition_resource, '$.section.*.text').length
      message_base = "List of Mandatory Must Support elements populated"

      show_message("#{message_base}: status: #{status}", status)
      show_message("#{message_base}: type: #{type}", type)
      show_message("#{message_base}: subject.reference: #{subject_reference}", subject_reference)
      show_message("#{message_base}: date: #{date}", date)
      show_message("#{message_base}: author: #{author}", author)
      show_message("#{message_base}: title: #{title}", title)
      show_message("#{message_base}: section.title: #{section_title}", section_title)
      show_message("#{message_base}: section.text: #{section_text}", section_text)

      text = JsonPath.on(composition_resource, '$.text').first.present?
      identifier = JsonPath.on(composition_resource, '$.identifier').first.present?
      asserter = JsonPath.on(composition_resource, '$.attester').first.present?
      asserter_mode = JsonPath.on(composition_resource, '$.attester.mode').first.present?
      asserter_time = JsonPath.on(composition_resource, '$.attester.time').first.present?
      asserter_party = JsonPath.on(composition_resource, '$.attester.party').first.present?
      custodian = JsonPath.on(composition_resource, '$.custodian').first.present?
      event = JsonPath.on(composition_resource, '$.event.code.coding.code').first.present?
      event_code = JsonPath.on(composition_resource, '$.event.code').first.present?
      event_period = JsonPath.on(composition_resource, '$.event.period').first.present?
      message_base = "List of Optional Must Support elements populated"

      show_message("#{message_base}: text: #{text}", text)
      show_message("#{message_base}: identifier: #{identifier}", identifier)
      show_message("#{message_base}: asserter: #{asserter}", asserter)
      show_message("#{message_base}: asserter.mode: #{asserter_mode}", asserter_mode)
      show_message("#{message_base}: asserter.time: #{asserter_time}", asserter_time)
      show_message("#{message_base}: asserter.party: #{asserter_party}", asserter_party)
      show_message("#{message_base}: custodian: #{custodian}", custodian)
      show_message("#{message_base}: event: #{event}", event)
      show_message("#{message_base}: event.code: #{event_code}", event_code)
      show_message("#{message_base}: event.period: #{event_period}", event_period)
    end

    run do
      composition_mandatory_ms_elements_info
    end
  end
end
