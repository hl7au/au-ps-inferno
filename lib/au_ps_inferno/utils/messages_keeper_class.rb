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
end
