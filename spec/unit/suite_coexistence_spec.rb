# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/generator/suite_file_generator'

RSpec.describe 'generated suites coexisting with the hand-authored suite' do
  it 'loads a freshly generated suite into the same process as au_ps_v100 with no id collisions' do
    fake_metadata = double(
      composition_sections: [{ code: '11450-4', required: true }],
      composition_mandatory_ms_elements: %w[author date],
      composition_optional_ms_elements: [],
      composition_mandatory_ms_sub_elements: [],
      composition_optional_ms_sub_elements: [],
      composition_mandatory_ms_slices: [],
      composition_optional_ms_slices: [],
      profiles: [
        { url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient', name: 'AUPSPatient',
          required: true }
      ]
    )
    # Generated code requires the shared lib/au_ps_inferno/utils/ tree via relative paths, so this
    # writes into the real lib/au_ps_inferno/ (like the real generator does for a real IG version),
    # under a version string that can't collide with a real one, and cleans up afterwards.
    lib_root = File.expand_path('../../lib/au_ps_inferno', __dir__)
    ig_version = '0.0.0-coexistence-test'
    version_dir = File.join(lib_root, 'generated', ig_version)

    begin
      Generator::SuiteFileGenerator.new(fake_metadata, ig_version, lib_root).generate
      suite_file = Dir[File.join(version_dir, 'suite', '*_suite.rb')].first

      # Inferno only registers a Runnable class into its repository via a TracePoint installed
      # for the duration of the app's one-time suite-loading boot pass (see inferno_core's
      # config/boot/suites.rb), not via `inherited`. Since this suite is generated and required
      # well after that boot pass has already run and been disabled, re-create that TracePoint
      # window here to faithfully reproduce what happens when a real generated suite is required
      # as part of normal boot.
      trace = TracePoint.trace(:end) do |tp|
        if tp.self < Inferno::Entities::Test || tp.self < Inferno::Entities::TestGroup ||
           tp.self < Inferno::Entities::TestSuite || tp.self < Inferno::Entities::TestKit
          tp.self.add_self_to_repository
        end
      end
      begin
        require suite_file
      ensure
        trace.disable
      end

      repo = Inferno::Repositories::TestSuites.new
      ids = repo.all.map { |suite| suite.id.to_s }

      expect(ids).to include('au_ps_v100')
      expect(ids).to include('suite_0_0_0_coexistence_test')
      expect(ids.tally.select { |_, count| count > 1 }).to be_empty
    ensure
      FileUtils.rm_rf(version_dir)
    end
  end
end
