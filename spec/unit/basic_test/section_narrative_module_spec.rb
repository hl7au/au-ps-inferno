# frozen_string_literal: true

require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/section_narrative_module'
require_relative '../../support/basic_test/basic_test_instance_setup'

RSpec.describe AUPSTestKit::BasicTestSectionNarrativeModule do
  include_context 'basic test instance setup'

  def section_with_text(status: 'generated', div: nil)
    text = div.nil? ? nil : FHIR::Narrative.new(status: status, div: div)
    FHIR::Composition::Section.new(text: text)
  end

  describe '#section_narrative_body' do
    it 'converts a simple narrative div to Markdown and reports the narrative status' do
      section = section_with_text(
        status: 'generated',
        div: '<div xmlns="http://www.w3.org/1999/xhtml">21/12/2024 No current problem or disability.</div>'
      )

      result = test_instance.section_narrative_body(section)

      expect(result).to eq(
        "Narrative status: `generated`\n\n21/12/2024 No current problem or disability."
      )
    end

    it 'converts an HTML table narrative into Markdown table syntax' do
      section = section_with_text(
        status: 'generated',
        div: '<div xmlns="http://www.w3.org/1999/xhtml"><table><thead><tr><th>Medicine</th><th>Dose</th></tr></thead>' \
             '<tbody><tr><td>Bisoprolol</td><td>2.5mg</td></tr></tbody></table></div>'
      )

      result = test_instance.section_narrative_body(section)

      expect(result).to eq(
        "Narrative status: `generated`\n\n" \
        "| Medicine | Dose |\n" \
        "| --- | --- |\n" \
        '| Bisoprolol | 2.5mg |'
      )
    end

    it 'converts a link narrative into Markdown link syntax, keeping only safe protocols' do
      section = section_with_text(
        status: 'generated',
        div: '<div xmlns="http://www.w3.org/1999/xhtml">' \
             '<a href="mailto:info@example.com">info@example.com</a></div>'
      )

      result = test_instance.section_narrative_body(section)

      expect(result).to eq(
        "Narrative status: `generated`\n\n[info@example.com](mailto:info@example.com)"
      )
    end

    it 'flags empty-status placeholder narrative so it is visible to a reviewer' do
      section = section_with_text(
        status: 'empty',
        div: '<div xmlns="http://www.w3.org/1999/xhtml">No information available</div>'
      )

      result = test_instance.section_narrative_body(section)

      expect(result).to eq("Narrative status: `empty`\n\nNo information available")
    end

    it 'returns a fallback message when the section has no text element at all' do
      section = section_with_text(div: nil)

      result = test_instance.section_narrative_body(section)

      expect(result).to eq('No narrative (`text`) present for this section.')
    end

    it 'never passes through raw HTML/script markup from the narrative div' do
      section = section_with_text(
        status: 'generated',
        div: '<div xmlns="http://www.w3.org/1999/xhtml"><script>alert(1)</script><p>Safe text</p></div>'
      )

      result = test_instance.section_narrative_body(section)

      expect(result).to include('Safe text')
      expect(result).not_to include('<script>')
      expect(result).not_to include('alert(1)')
    end

    it 'strips http(s) img src so a narrative cannot be used as a tracking pixel' do
      section = section_with_text(
        status: 'generated',
        div: '<div xmlns="http://www.w3.org/1999/xhtml">' \
             '<img src="https://example.invalid/pixel.gif" alt="tracker"></div>'
      )

      result = test_instance.section_narrative_body(section)

      expect(result).not_to include('example.invalid')
      expect(result).not_to include('https://')
    end

    it 'keeps data URI img src so self-contained narrative images still render' do
      data_uri = 'data:image/png;base64,iVBORw0KGgo='
      section = section_with_text(
        status: 'generated',
        div: "<div xmlns=\"http://www.w3.org/1999/xhtml\"><img src=\"#{data_uri}\" alt=\"inline\"></div>"
      )

      result = test_instance.section_narrative_body(section)

      expect(result).to include(data_uri)
    end

    it 'strips event-handler attributes even from tags reverse_markdown has no converter for' do
      section = section_with_text(
        status: 'generated',
        div: '<div xmlns="http://www.w3.org/1999/xhtml">' \
             '<u onmouseover="alert(1)">hover me</u><a href="javascript:alert(2)">click</a></div>'
      )

      result = test_instance.section_narrative_body(section)

      expect(result).not_to include('onmouseover')
      expect(result).not_to include('javascript:')
      expect(result).not_to include('alert(1)')
      expect(result).not_to include('alert(2)')
    end
  end
end
