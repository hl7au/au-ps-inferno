# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/utils/basic_test/composition_section_read_module'

module CompositionSectionsCheckSuiteKit
  class CompositionSectionsCheckSuite < Inferno::TestSuite
    include AUPSTestKit::BasicTestCompositionSectionReadModule

    id :composition_sections_check_suite

    test do
      id :sections_shall_populated
      title 'Sections SHALL be correctly populated'
      description 'Verify that the sections are correctly populated'

      run do
        test_composition_mandatory_sections
      end
    end

    test do
      id :sections_should_populated
      title 'Sections SHOULD be correctly populated'
      description 'Verify that the sections are correctly populated'

      run do
        test_composition_recommended_sections
      end
    end

    test do
      id :sections_may_populated
      title 'Sections MAY be correctly populated'
      description 'Verify that the sections are correctly populated'

      run do
        test_composition_optional_sections
      end
    end
  end
end
