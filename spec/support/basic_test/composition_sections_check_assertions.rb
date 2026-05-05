# frozen_string_literal: true

module CompositionSectionsCheckAssertions
  def expect_info_messages(outcome, messages_array)
    messages_array.each { |message| expect_info_message(outcome, message) }
  end

  def expect_warning_messages(outcome, messages_array)
    messages_array.each { |message| expect_warning_message(outcome, message) }
  end

  def expect_error_messages(outcome, messages_array)
    messages_array.each { |message| expect_error_message(outcome, message) }
  end

  def expect_info_message(outcome, expected_message)
    expect(outcome[:messages]).to include_message(type: 'info', text: expected_message)
  end

  def expect_warning_message(outcome, expected_message)
    expect(outcome[:messages]).to include_message(type: 'warning', text: expected_message)
  end

  def expect_error_message(outcome, expected_message)
    expect(outcome[:messages]).to include_message(type: 'error', text: expected_message)
  end

  def outcome_expect_to_status(outcome, status)
    expect(outcome[:result].result).to(eq(status))
  end

  def expect_pass(outcome)
    outcome_expect_to_status(outcome, 'pass')
  end

  def expect_fail(outcome)
    outcome_expect_to_status(outcome, 'fail')
  end

  def expect_skip(outcome)
    outcome_expect_to_status(outcome, 'skip')
  end

  def expect_result_and_messages(result:, messages:, status:, expected_messages:)
    expect(result.result).to eq(status), result.result_message
    expect_messages(messages, expected_messages)
  end

  def expect_messages(messages, expected_messages)
    expect(messages.size).to eq(expected_messages.size)
    expected_messages.each do |expected_message|
      expect(messages).to include_message(type: expected_message[:type], text: expected_message[:text])
    end
  end
end
