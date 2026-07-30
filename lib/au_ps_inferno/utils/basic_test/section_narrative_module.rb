# frozen_string_literal: true

require 'reverse_markdown'
require 'sanitize'

module AUPSTestKit
  # Converts Composition.section.text (Narrative) into a displayable message.
  module BasicTestSectionNarrativeModule
    NARRATIVE_SANITIZE_CONFIG = Sanitize::Config.merge(
      Sanitize::Config::BASIC,
      elements: Sanitize::Config::BASIC[:elements] + %w[
        div span hr img table caption thead tbody tfoot tr th td h1 h2 h3 h4 h5 h6
      ],
      attributes: Sanitize::Config.merge(
        Sanitize::Config::BASIC[:attributes],
        'span' => %w[title],
        'img' => %w[alt src title],
        'th' => %w[colspan rowspan],
        'td' => %w[colspan rowspan]
      ),
      protocols: Sanitize::Config.merge(
        Sanitize::Config::BASIC[:protocols],
        'img' => { 'src' => ['http', 'https', :relative] }
      )
    ).freeze

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
      Sanitize.fragment(div, NARRATIVE_SANITIZE_CONFIG)
    end
  end
end
