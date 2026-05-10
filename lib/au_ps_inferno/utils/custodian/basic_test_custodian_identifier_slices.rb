# frozen_string_literal: true

module AUPSTestKit
  # Custodian Must Support identifier slices (Organization).
  module BasicTestCustodianIdentifierSlices
    def validate_custodian_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      custodian_header = custodian_identifier_slices_header(resource_type_str, profile_str)
      slice_results = custodian_identifier_slice_results(identifiers_from_resource(resource) || [], slices)
      custodian_post_identifier_slices_message(custodian_header, slice_results)
    end

    private

    def custodian_identifier_slices_header(resource_type_str, profile_str)
      "**Referenced custodian**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
    end

    def custodian_identifier_slice_results(identifiers, slices)
      slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end
    end

    def custodian_post_identifier_slices_message(custodian_header, slice_results)
      lines = slice_results.map { |result| custodian_identifier_slice_line(result) }
      message_type = slice_results.all? { |r| r[:identifier].present? } ? 'info' : 'warning'
      add_message(message_type, custodian_identifier_slices_full_message(custodian_header, lines))
    end

    def custodian_identifier_slice_line(result)
      if result[:identifier].present?
        type_str = identifier_type_display(result[:identifier])
        "✅ Populated: **#{result[:slice][:name]}** — system: #{result[:slice][:system]}#{type_str}"
      else
        "⚠️ Missing: **#{result[:slice][:name]}**"
      end
    end

    def custodian_identifier_slices_full_message(custodian_header, lines)
      heading = '## List of Must Support identifier slices populated or missing (type and system when populated)'
      ['Must support identifier slices correctly populated', custodian_header, heading, lines.join("\n\n")].join("\n\n")
    end
  end
end
