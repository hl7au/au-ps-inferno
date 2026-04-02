# frozen_string_literal: true

require_relative 'rich_message_class'

# A class to keep messages for a section test
class MessagesKeeper
  attr_reader :messages

  def initialize
    @messages = []
  end

  def add_message(message)
    @messages << message
  end
end
