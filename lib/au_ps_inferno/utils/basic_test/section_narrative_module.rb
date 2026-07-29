# frozen_string_literal: true

require 'nokogiri'
require 'reverse_markdown'

module AUPSTestKit
  # Converts Composition.section.text (Narrative) into a displayable message.
  module BasicTestSectionNarrativeModule
    # Elements that must never survive into the converted Markdown, even though FHIR's
    # restricted narrative XHTML subset already disallows them (defense in depth).
    UNSAFE_NARRATIVE_ELEMENTS = 'script, style, iframe, object, embed'

    def section_narrative_body(section)
      div = section&.text&.div
      return 'No narrative (`text`) present for this section.' if div.blank?

      status = section.text.status
      markdown = ReverseMarkdown.convert(sanitized_narrative_html(div), github_flavored: true).strip
      markdown = '_(narrative converted to Markdown is empty)_' if markdown.blank?

      "Narrative status: `#{status}`\n\n#{markdown}"
    end

    private

    def sanitized_narrative_html(div)
      fragment = Nokogiri::HTML::DocumentFragment.parse(div)
      fragment.css(UNSAFE_NARRATIVE_ELEMENTS).remove
      fragment.to_html
    end
  end
end
