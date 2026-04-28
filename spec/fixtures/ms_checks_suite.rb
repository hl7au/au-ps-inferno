# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'

module MSCheckSuiteKit
  class MSCheckSuite < Inferno::TestSuite
    include AUPSTestKit::BasicTestCompositionSectionReadModule

    id :ms_check_suite

    test do
      id :mandatory_ms_elements_populated
      title 'Mandatory MS elements populated'
      description 'Verify that the mandatory MS elements are populated'

      run do
        test_composition_mandatory_sections
      end
    end
  end
end
