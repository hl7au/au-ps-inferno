# frozen_string_literal: true

RSpec.describe 'IG version source consistency' do
  # Shared code (used by every IG version's suite) must never pin a specific IG version:
  # the fhir_resource_validator's `igs` line is the single source of truth per suite, and an
  # unversioned profile canonical resolves against whatever that suite loaded. A hardcoded
  # version literal here is a drift vector (see issue #87) that silently breaks every IG
  # version other than the one it happens to match.
  let(:shared_lib_files) { Dir.glob(File.expand_path('../../lib/au_ps_inferno/utils/**/*.rb', __dir__)) }
  let(:version_pin_pattern) { %r{(StructureDefinition/[\w-]+|hl7\.fhir\.au\.ps)#?\|?['"]?\d+\.\d+\.\d+} }

  it 'contains no hardcoded IG version literal in shared (non-versioned) code' do
    offenders = shared_lib_files.select { |path| File.read(path).match?(version_pin_pattern) }

    expect(offenders).to be_empty,
                         "Found hardcoded IG version pin(s) in shared code: #{offenders.join(', ')}"
  end

  # The global AUPSTestKit::IG_VERSION constant can only hold one value at a time, so shared
  # code depending on it would silently be wrong for every IG version except that one, once
  # multiple versions coexist (see docs/plans/ig-version-specific-suites.md).
  it 'contains no reference to the global IG_VERSION constant in shared (non-versioned) code' do
    offenders = shared_lib_files.select { |path| File.read(path).include?('IG_VERSION') }

    expect(offenders).to be_empty,
                         "Found a reference to the global IG_VERSION constant in shared code: #{offenders.join(', ')}"
  end
end
