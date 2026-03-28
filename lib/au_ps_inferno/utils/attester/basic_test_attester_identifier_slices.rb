# frozen_string_literal: true

module AUPSTestKit
  # Must Support identifier slice validation for Composition attester.party reference.
  module BasicTestAttesterIdentifierSlices
    def validate_attester_party_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      identifiers = identifiers_from_resource(resource) || []
      slice_results = attester_party_build_slice_results(slices, identifiers)
      header = attester_party_referenced_type_profile_header(resource_type_str, profile_str)
      lines = slice_results.map { |r| attester_party_format_identifier_slice_line(r) }
      message_type = slice_results.all? { |r| r[:identifier].present? } ? 'info' : 'warning'
      add_message(message_type, attester_party_identifier_slices_full_message(header, lines))
    end

    def test_composition_attester_party_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = attester_party_resource
      skip_if resource.blank?, 'Attester or attester.party is not populated'

      resource_type_str = resource_type(resource)
      slices = AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE[resource_type_str] || []
      skip_if slices.blank?, 'Referenced attester.party resource type has no Must Support identifier slices'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_attester_party_ms_identifier_slices(resource, slices, rtype_str, profile_str)
    end

    private

    def attester_party_build_slice_results(slices, identifiers)
      slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end
    end

    def attester_party_format_identifier_slice_line(result)
      if result[:identifier].present?
        type_str = identifier_type_display(result[:identifier])
        "✅ Populated: **#{result[:slice][:name]}** — system: #{result[:slice][:system]}#{type_str}"
      else
        "❌ Missing: **#{result[:slice][:name]}**"
      end
    end

    def attester_party_identifier_slices_full_message(header, lines)
      attester_party_join_message_sections(
        attester_party_identifier_slices_message_parts(header, lines)
      )
    end

    def attester_party_identifier_slices_message_parts(header, lines)
      [
        'Must support identifier slices correctly populated', '',
        header, '',
        attester_party_identifier_slices_heading, '',
        lines.join("\n\n")
      ]
    end

    def attester_party_identifier_slices_heading
      [
        '## List of Must Support identifier slices populated or missing',
        '(type and system when populated)'
      ].join(' ')
    end
  end
end
