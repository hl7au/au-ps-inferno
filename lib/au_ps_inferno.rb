# frozen_string_literal: true

Dir.glob(File.join(__dir__, 'au_ps_inferno', '*', '*_suite.rb')).each { |file| require_relative file }
