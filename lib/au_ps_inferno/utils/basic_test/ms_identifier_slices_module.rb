# frozen_string_literal: true

module AUPSTestKit
  # Must Support identifier slices (IHI, DVA, Medicare) on a resource (e.g. Patient).
  module BasicTestMsIdentifierSlicesModule
    private

    # Validates Must Support identifier slices (IHI, DVA, Medicare) on a resource (e.g. Patient).
    # Two messages: (1) Must support identifier slices correctly populated; (2) At least one slice populated.
    # Pass: all messages info or warning. No error level used.
    #
    # @param resource [Hash, FHIR::Model] The resource with identifier array (e.g. Patient)
    # @param slices [Array<Hash>] Each hash has :name (String) and :system (String URL)
    def validate_ms_identifier_slices_in_resource(resource, slices)
      return unless resource.present?

      slice_results = build_ms_identifier_slice_results(identifiers_from_resource(resource) || [], slices)
      add_ms_identifier_slices_populated_message(slice_results)
      add_ms_identifier_slices_at_least_one_message(slice_results)
    end

    def add_ms_identifier_slices_populated_message(slice_results)
      lines = slice_results.map { |r| ms_identifier_slice_line_with_type(r) }
      heading = '## List of Must Support identifier slices populated or missing'
      body = ['Must support identifier slices correctly populated', heading, lines.join("\n\n")].join("\n\n")
      add_message(slice_results.all? { |r| r[:identifier].present? } ? 'info' : 'warning', body)
    end

    def add_ms_identifier_slices_at_least_one_message(slice_results)
      lines = slice_results.map { |r| ms_identifier_slice_line_system_only(r) }
      heading = '## List of Must Support identifier slices populated or missing (system when populated)'
      intro = 'At least one Must Support identifier slices is populated'
      body = [intro, heading, lines.join("\n\n")].join("\n\n")
      add_message(slice_results.any? { |r| r[:identifier].present? } ? 'info' : 'warning', body)
    end

    def build_ms_identifier_slice_results(identifiers, slices)
      slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end
    end

    def ms_identifier_slice_line_with_type(result)
      if result[:identifier].present?
        type_str = identifier_type_display(result[:identifier])
        "✅ Populated: **#{result[:slice][:name]}** — system: #{result[:slice][:system]}#{type_str}"
      else
        "⚠️ Missing: **#{result[:slice][:name]}**"
      end
    end

    def ms_identifier_slice_line_system_only(result)
      if result[:identifier].present?
        "✅ Populated: **#{result[:slice][:name]}** — system: #{result[:slice][:system]}"
      else
        "⚠️ Missing: **#{result[:slice][:name]}**"
      end
    end
  end
end
