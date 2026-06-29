# frozen_string_literal: true

RSpec::Matchers.define :include_message do |type:, text:|
  match do |messages|
    @matched_message = Array(messages).find do |message|
      next false unless message.respond_to?(:type) && message.respond_to?(:message)
      next false unless message.type == type

      text.is_a?(Regexp) ? text.match?(message.message) : message.message.include?(text.to_s)
    end

    !@matched_message.nil?
  end

  failure_message do |messages|
    available = Array(messages).map { |message| "[#{message.type}] #{message.message}" }
    "expected messages to include type=#{type.inspect}, text=#{text.inspect}; available: #{available.join(' | ')}"
  end
end
