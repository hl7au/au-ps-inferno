# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/utils/composition_utils'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'
require_relative 'composition_sections_check_assertions'
require_relative 'fhir_bundle_helpers'

module CompositionSectionsCheckSupport
  include CompositionSectionsCheckAssertions
  include FhirBundleHelpers

  def scratch_with(bundle)
    { bundle_ips_resource: bundle }
  end

  def messages_for(result)
    Inferno::Repositories::Messages.new.messages_for_result(result.id)
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
