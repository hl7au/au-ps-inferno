# frozen_string_literal: true

require_relative './cref_operation_support'
require_relative './docref_operation_success'

module AUPSTestKit
  # Tests for the $docref operation
  class DocRefOperation < Inferno::TestGroup
    title '$docref Operation Tests'
    description 'Verify support for the $docref operation as as described in the AU PS Guidance'
    id :au_ps_docref_operation_group
    run_as_group

    test from: :au_ps_docref_operation_support
    test from: :au_ps_docref_operation_success
  end
end
