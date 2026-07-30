# frozen_string_literal: true

require 'reverse_markdown'
require 'sanitize'

module AUPSTestKit
  # Converts Composition.section.text (Narrative) into a displayable message.
  module BasicTestSectionNarrativeModule
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
      Sanitize.fragment(div, Sanitize::Config::RESTRICTED)
    end
  end
end
