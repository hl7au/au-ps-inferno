# frozen_string_literal: true

MAX_LIB_BASENAME_BYTES = 95

RSpec.describe 'lib file basenames' do
  it 'stays within the ustar tar basename limit used by `gem build`' do
    lib_root = File.expand_path('../../lib', __dir__)
    files = Dir.glob(File.join(lib_root, '**', '*.rb'))

    offenders = files.select { |path| File.basename(path).bytesize > MAX_LIB_BASENAME_BYTES }

    expect(offenders).to be_empty, lambda {
      "these files have a basename over #{MAX_LIB_BASENAME_BYTES} bytes: " \
        "#{offenders.map { |f| File.basename(f) }.join(', ')}"
    }
  end
end
