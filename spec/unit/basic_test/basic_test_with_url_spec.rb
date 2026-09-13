# frozen_string_literal: true

require_relative '../../../lib/au_ps_inferno/utils/basic_test_with_url'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.describe AUPSTestKit::BasicTestWithURL do
  include_context 'when testing a runnable'

  let(:suite_id) { 'basic_test_with_url_test_suite' }
  let(:server_url) { 'https://example.com/fhir' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'basic_test_with_url_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?('basic_test_with_url_test_suite')
  end

  def create_test(test_id)
    klass = Class.new(described_class) do
      id test_id
      input :url, optional: true
      input :bundle_retrieve_method, optional: true
      run { omit_unless_fhir_server_bundle? }
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  it 'omits when the retrieval method is not fhir_server, even if a URL is present' do
    test = create_test('basic_test_with_url_wrong_method_test')
    result = run(test, { bundle_retrieve_method: 'bundle_url', url: server_url })

    expect(result.result).to eq('omit')
  end

  it 'omits when no URL is given, even if fhir_server is selected' do
    test = create_test('basic_test_with_url_blank_url_test')
    result = run(test, { bundle_retrieve_method: 'fhir_server' })

    expect(result.result).to eq('omit')
  end

  it 'runs when fhir_server is selected and a URL is given' do
    test = create_test('basic_test_with_url_runs_test')
    result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url })

    expect(result.result).to eq('pass')
  end
end
