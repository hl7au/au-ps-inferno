# frozen_string_literal: true

require_relative './summary_operation_return_bundle'

module AUPSTestKit
  class SummaryOperationGroup < Inferno::TestGroup
    title '$summary Operation: Validate Bundle'
    description 'Verify that the $summary operation returns a valid AU PS Bundle, or validate a provided Bundle.'
    id :au_ps_summary_operation
    run_as_group
    
    test from: :au_ps_summary_operation_return_bundle

  end
end
