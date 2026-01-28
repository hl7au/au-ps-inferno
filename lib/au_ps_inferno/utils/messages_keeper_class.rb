# frozen_string_literal: true

require_relative 'rich_message_class'

# A class to keep messages for a section test
class MessagesKeeper
  class << self
    def filtered_messages_by_signature(messages_array, signature)
      messages_array.select { |message| message.signature == signature }
    end
  end

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
      message.type == msg_type
    end
  end
end
