# frozen_string_literal: true

require 'au_ps_inferno/utils/validator_helpers'

# Minimal object that satisfies the contract expected by {ValidatorHelpers}
# (Inferno tests provide +scratch+, +info+, +warning+).
class ValidatorHelpersHost
  include ValidatorHelpers

  attr_accessor :scratch
  attr_reader :info_messages, :warning_messages

  def initialize
    @scratch = {}
    @info_messages = []
    @warning_messages = []
  end

  def info(msg = nil)
    info_messages << msg unless msg.nil?
    nil
  end

  def warning(msg = nil)
    warning_messages << msg unless msg.nil?
    nil
  end
end
