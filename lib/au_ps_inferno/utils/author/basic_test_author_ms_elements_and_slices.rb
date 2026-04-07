# frozen_string_literal: true

module AUPSTestKit
  # Author Must Support: flat elements and identifier slices.
  module BasicTestAuthorMsElementsAndSlices
    def validate_author_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      author_header = author_identifier_slices_header(resource_type_str, profile_str)
      slice_results = author_identifier_slice_results(identifiers_from_resource(resource) || [], slices)
      author_post_identifier_slices_messages(author_header, slice_results)
    end

    private

    def author_identifier_slices_header(resource_type_str, profile_str)
      "**Referenced author**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
    end

    def author_post_identifier_slices_messages(author_header, slice_results)
      lines = slice_results.map { |result| author_identifier_slice_line(result) }
      message_type = slice_results.all? { |r| r[:identifier].present? } ? 'info' : 'warning'
      add_message(message_type, author_identifier_slices_full_message(author_header, lines))
    end

    def author_identifier_slice_results(identifiers, slices)
      slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end
    end

    def author_identifier_slice_line(result)
      if result[:identifier].present?
        type_str = identifier_type_display(result[:identifier])
        "✅ Populated: **#{result[:slice][:name]}** — system: #{result[:slice][:system]}#{type_str}"
      else
        "❌ Missing: **#{result[:slice][:name]}**"
      end
    end

    def author_identifier_slices_full_message(author_header, lines)
      heading = '## List of Must Support identifier slices populated or missing (type and system when populated)'
      parts = ['Must support identifier slices correctly populated', author_header, heading, lines.join("\n\n")]
      parts.join("\n\n")
    end
  end
end
