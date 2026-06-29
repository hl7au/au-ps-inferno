# frozen_string_literal: true

RSpec.shared_context 'basic test instance setup' do
  let(:test_class) do
    Class.new(AUPSTestKit::BasicTest) do
      attr_accessor :metadata_manager
    end
  end
  let(:test_instance) { test_class.new }
end
