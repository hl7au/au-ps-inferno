# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/utils/composition_utils'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'
require_relative 'composition_sections_check_assertions'
require_relative 'composition_sections_constants'
require_relative 'composition_sections_metadata'
require_relative 'fhir_bundle_helpers'

module CompositionSectionsCheckSupport
  include CompositionSectionsCheckAssertions
  include CompositionSectionsConstants
  include CompositionSectionsMetadata
  include FhirBundleHelpers

  def configure_test_class(test_class, metadata)
    manager = AUPSTestKit::MetadataManager.new(nil).tap do |m|
      allow(m).to receive(:metadata).and_return(metadata)
    end
    test_class.class_eval do
      include CompositionUtils unless ancestors.include?(CompositionUtils)
      unless ancestors.include?(AUPSTestKit::BasicTestCompositionSectionReadModule)
        include AUPSTestKit::BasicTestCompositionSectionReadModule
      end
      define_method(:metadata_manager) { manager }
    end
  end

  def run_test(scratch)
    run(test, {}, scratch)
  end

  def scratch_with(bundle)
    { bundle_ips_resource: bundle }
  end

  def run_with_sections(test, sections:, extra_entries: [])
    bundle = build_bundle(sections: sections, extra_entries: extra_entries)
    result = run(test, {}, scratch_with(bundle))
    { result: result, messages: messages_for(result) }
  end

  def messages_for(result)
    Inferno::Repositories::Messages.new.messages_for_result(result.id)
  end
end

RSpec.shared_examples 'skips when no bundle is provided' do
  it 'skips when no bundle is provided in scratch' do
    result = run_test({})

    expect(result.result).to eq('skip')
    expect(messages_for(result)).to be_empty
  end
end

RSpec.shared_context 'composition sections check setup' do
  include CompositionSectionsCheckSupport

  let(:suite_id) { 'composition_sections_check_suite' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'composition_sections_check_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?(suite_id)
  end

  def find_test(method_name)
    test_id = "#{suite_id}-#{method_name}"
    test_class = Class.new(Inferno::Test) do
      id test_id
      run { send(method_name) }
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(test_class) unless repo.exists?(test_id)
    test_class
  end
end
