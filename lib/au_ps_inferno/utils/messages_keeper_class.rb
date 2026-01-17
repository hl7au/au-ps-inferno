# frozen_string_literal: true

# A class to keep messages for a section test
class MessagesKeeper
  attr_reader :messages

  def initialize
    @messages = []
  end

  def add_message(message)
    @messages << message
  end

  def errors
    messages_of_type('error')
  end

  def warnings
    messages_of_type('warning')
  end

  private

  def messages_of_type(msg_type)
    @messages.filter do |message|
      message[:type] == msg_type
    end
  end
end
