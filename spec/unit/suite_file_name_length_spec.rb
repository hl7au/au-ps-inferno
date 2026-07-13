# frozen_string_literal: true

MAX_LIB_BASENAME_BYTES = 95

RSpec.describe 'generated suite file basenames' do
  it 'stays within the ustar tar basename limit used by `gem build`' do
    # Scoped to lib/au_ps_inferno/generated/, not all of lib/, because the hand-authored suite
    # under lib/au_ps_inferno/suite/ already has file basenames over this limit and is out of
    # scope to change - this spec only guards the naming scheme SuiteSpec/SuiteFileGenerator use
    # for generated versions.
    generated_root = File.expand_path('../../lib/au_ps_inferno/generated', __dir__)
    files = Dir.glob(File.join(generated_root, '**', '*.rb'))

    offenders = files.select { |path| File.basename(path).bytesize > MAX_LIB_BASENAME_BYTES }

    expect(offenders).to be_empty, lambda {
      "these files have a basename over #{MAX_LIB_BASENAME_BYTES} bytes: " \
        "#{offenders.map { |f| File.basename(f) }.join(', ')}"
    }
  end
end
