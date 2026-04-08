# frozen_string_literal: true

require_relative 'bundle_decorator'
require_relative 'composition_utils'
require_relative 'validator_helpers'
require_relative 'section_test_module'
require_relative 'section_names_mapping'
require_relative 'basic_test_contants_module'
require_relative 'attester/basic_test_attester_module'
require_relative 'subject/basic_test_subject_module'
require_relative 'author/basic_test_author_module'
require_relative 'custodian/basic_test_custodian_module'
require_relative 'basic_test/bundle_module'
require_relative 'basic_test/capability_operations_module'
require_relative 'basic_test/composition_section_read_module'
require_relative 'basic_test/paths_module'
require_relative 'basic_test/resource_helpers_module'
require_relative 'basic_test/composition_subelements_module'
require_relative 'basic_test/ms_identifier_slices_module'
require_relative 'basic_test/composition_elements_and_slices_module'
require_relative 'basic_test/section_bundle_validation_module'
require_relative 'basic_test/resolve_path_debug_module'
require_relative 'basic_test/scratch_bundle_entries_module'
require_relative 'basic_test/ms_elements_populated_module'
require_relative 'basic_test/ms_sub_elements_populated_module'

module AUPSTestKit
  # A base class for all tests to decrease code duplication.
  # Shared behavior is composed from BasicTest* modules under utils/basic_test/.
  class BasicTest < Inferno::Test
    include CompositionUtils
    include ValidatorHelpers
    include SectionTestModule
    include SectionNamesMapping
    include BasicTestConstants
    include BasicTestSubjectModule
    include BasicTestAuthorModule
    include BasicTestCustodianModule
    include BasicTestAttesterModule
    include BasicTestBundleModule
    include BasicTestCapabilityOperationsModule
    include BasicTestCompositionSectionReadModule
    include BasicTestPathsModule
    include BasicTestResourceHelpersModule
    include BasicTestCompositionSubelementsModule
    include BasicTestMsIdentifierSlicesModule
    include BasicTestCompositionElementsAndSlicesModule
    include BasicTestSectionBundleValidationModule
    include BasicTestResolvePathDebugModule
    include BasicTestScratchBundleEntriesModule
    include BasicTestMsElementsPopulatedModule
    include BasicTestMsSubElementsPopulatedModule
  end
end
