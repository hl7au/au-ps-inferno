# frozen_string_literal: true

require_relative '../../../../spec_helper'
require_relative '../../../../support/resolve_resource_type_module_host'

# rubocop:disable Metrics/BlockLength -- example groups map 1:1 to branches under test
RSpec.describe AUPSTestKit::BasicTestResolveResourceTypeModule do
  let(:host) { AUPSTestKit::ResolveResourceTypeModuleHost.new }

  describe '#raw_resource_type_is_valid' do
    context 'when the reference does not resolve' do
      it 'returns invalid with a not-resolved message for nil resource' do
        host.resolved_resource = nil
        host.metadata_entries = [{ resource_type: 'Patient' }]

        result = host.raw_resource_type_is_valid('subject')

        expect(result[:valid?]).to be false
        expect(result[:msg]).to eq('Subject reference does not resolve')
      end

      it 'returns invalid for blank string resource' do
        host.resolved_resource = ''
        host.metadata_entries = [{ resource_type: 'Patient' }]

        result = host.raw_resource_type_is_valid('author')

        expect(result[:valid?]).to be false
        expect(result[:msg]).to eq('Author reference does not resolve')
      end
    end

    context 'when the resolved type is not allowed' do
      it 'returns invalid with the resolved type in the message' do
        host.resolved_resource = { 'resourceType' => 'Organization' }
        host.metadata_entries = [{ resource_type: 'Patient' }]

        result = host.raw_resource_type_is_valid('subject')

        expect(result[:valid?]).to be false
        expect(result[:msg]).to eq(
          'Subject reference resolves to a resource with invalid resource type: Organization'
        )
      end
    end

    context 'when the resolved type is allowed' do
      it 'returns valid for a Hash resource' do
        host.resolved_resource = { 'resourceType' => 'Patient' }
        host.metadata_entries = [{ resource_type: 'Patient' }, { resource_type: 'Group' }]

        result = host.raw_resource_type_is_valid('subject')

        expect(result[:valid?]).to be true
        expect(result[:msg]).to eq(
          'Subject reference resolves to a resource with valid resource type: Patient'
        )
      end

      it 'returns valid for an object with resourceType' do
        resource = Struct.new(:resourceType).new('Patient')
        host.resolved_resource = resource
        host.metadata_entries = [{ resource_type: 'Patient' }]

        result = host.raw_resource_type_is_valid('custodian')

        expect(result[:valid?]).to be true
        expect(result[:msg]).to include('Custodian reference resolves')
        expect(result[:msg]).to include('Patient')
      end
    end
  end

  describe '#test_resource_type_is_valid?' do
    it 'adds an info message and does not raise when valid' do
      host.resolved_resource = { 'resourceType' => 'Patient' }
      host.metadata_entries = [{ resource_type: 'Patient' }]

      expect { host.test_resource_type_is_valid?('subject') }.not_to raise_error

      expect(host.messages.last).to eq(
        [
          'info',
          'Subject reference resolves to a resource with valid resource type: Patient'
        ]
      )
      expect(host.assertions.last).to eq(
        [
          true,
          'Subject reference resolves to a resource with valid resource type: Patient'
        ]
      )
    end

    it 'adds an error message and raises when the reference does not resolve' do
      host.resolved_resource = nil
      host.metadata_entries = [{ resource_type: 'Patient' }]

      expect { host.test_resource_type_is_valid?('author') }.to raise_error(
        RuntimeError,
        'Author reference does not resolve'
      )

      expect(host.messages.last).to eq(['error', 'Author reference does not resolve'])
    end

    it 'adds an error message and raises when the resource type is invalid' do
      host.resolved_resource = { 'resourceType' => 'Observation' }
      host.metadata_entries = [{ resource_type: 'Patient' }]

      msg = 'Subject reference resolves to a resource with invalid resource type: Observation'
      expect { host.test_resource_type_is_valid?('subject') }.to raise_error(RuntimeError, msg)

      expect(host.messages.last).to eq(['error', msg])
    end
  end
end
# rubocop:enable Metrics/BlockLength
