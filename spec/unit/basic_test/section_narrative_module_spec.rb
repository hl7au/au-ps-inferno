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
        div: '<div xmlns="http://www.w3.org/1999/xhtml"><table><thead><tr><th>Medicine</th></tr></thead>' \
             '<tbody><tr><td>Bisoprolol</td></tr></tbody></table></div>'
      )

      result = test_instance.section_narrative_body(section)

      expect(result).to start_with("Narrative status: `generated`\n\n")
      expect(result).to include('Medicine')
      expect(result).to include('Bisoprolol')
      expect(result).not_to include('<table>')
      expect(result).not_to include('<td>')
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
  end
end
