# frozen_string_literal: true

require 'cgi'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/section_decorator'
require_relative '../../support/basic_test/basic_test_instance_setup'

RSpec.describe AUPSTestKit::BasicTestSectionBundleValidationModule do
  include_context 'basic test instance setup'

  def section_title_expression
    "Bundle.entry.where(resource is Composition).resource.section.where(code.coding.code='11450-4').title"
  end

  def build_section(title: 'Patient Summary Problems Section', status: 'generated', narrative: 'Some narrative text.')
    SectionDecorator.new(
      title: title,
      code: FHIR::CodeableConcept.new(coding: [FHIR::Coding.new(code: '11450-4', display: title)]),
      text: FHIR::Narrative.new(status: status, div: "<div xmlns=\"http://www.w3.org/1999/xhtml\">#{narrative}</div>")
    )
  end

  describe '#section_ms_elements_message (private)' do
    it 'combines the Must Support population status and the converted narrative in a single body' do
      section = build_section
      result = test_instance.send(:section_ms_elements_message, section, %w[title code text])

      expect(result).to include('List of Must Support elements populated or missing:')
      expect(result).to include('**title**:')
      expect(result).to include('Narrative status: `generated`')
      expect(result).to include('Some narrative text.')
    end

    it 'links the short element name to fhirpath-lab, evaluating the full Bundle-rooted expression, ' \
       'once the Bundle URL is known' do
      test_instance.scratch[:bundle_ips_resource_url] = 'https://example.com/fhir/Bundle/doc-1'
      section = build_section
      result = test_instance.send(:section_ms_elements_message, section, %w[title code text])

      expect(result).to include(
        '**[title](https://fhirpath-lab.com/FhirPath?' \
        "expression=#{CGI.escape(section_title_expression)}" \
        '&engine=fhirpath.js&resource=https%3A%2F%2Fexample.com%2Ffhir%2FBundle%2Fdoc-1)**:'
      )
    end
  end

  describe '#section_bundle_ms_population_outcome? (private)' do
    it 'keeps the narrative content in the same message as the "correctly populated" status' do
      section = build_section

      test_instance.send(:section_bundle_ms_population_outcome?, section, %w[title code text])

      expect(test_instance.messages.size).to eq(1)
      message = test_instance.messages.first
      expect(message[:type]).to eq('info')
      expect(message[:message]).to include('Section correctly populated')
      expect(message[:message]).to include('Narrative status: `generated`')
      expect(message[:message]).to include('Some narrative text.')
    end

    it 'keeps the narrative content in the same message as the missing-mandatory error status' do
      section = build_section(title: nil)

      test_instance.send(:section_bundle_ms_population_outcome?, section, %w[title code text])

      expect(test_instance.messages.size).to eq(1)
      message = test_instance.messages.first
      expect(message[:type]).to eq('error')
      expect(message[:message]).to include('For section with any mandatory Must Support element in section missing')
      expect(message[:message]).to include('Narrative status: `generated`')
      expect(message[:message]).to include('Some narrative text.')
    end

    it 'flags placeholder narrative (status: empty) alongside a passing population status' do
      section = build_section(status: 'empty', narrative: 'No information available')

      test_instance.send(:section_bundle_ms_population_outcome?, section, %w[title code text])

      message = test_instance.messages.first
      expect(message[:type]).to eq('info')
      expect(message[:message]).to include('Narrative status: `empty`')
      expect(message[:message]).to include('No information available')
    end
  end
end
