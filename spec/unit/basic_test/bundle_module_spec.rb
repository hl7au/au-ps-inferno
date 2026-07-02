# frozen_string_literal: true

require_relative '../../support/basic_test/basic_test_instance_setup'

RSpec.describe AUPSTestKit::BasicTestBundleModule do
  include_context 'basic test instance setup'

  describe '#validate_au_ps_bundle' do
    it 'pins the AU PS Bundle profile to the current metadata_manager IG version' do
      test_instance.metadata_manager = instance_double(AUPSTestKit::MetadataManager, ig_version: '1.0.0-ballot')

      expect(test_instance).to receive(:validate_bundle_wrapper)
        .with('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|1.0.0-ballot')

      test_instance.validate_au_ps_bundle
    end
  end

  describe '#validate_ips_bundle' do
    it 'validates against the unversioned IPS Bundle profile' do
      expect(test_instance).to receive(:validate_bundle_wrapper)
        .with('http://hl7.org/fhir/uv/ips/StructureDefinition/Bundle-uv-ips')

      test_instance.validate_ips_bundle
    end
  end
end
