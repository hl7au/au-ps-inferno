# frozen_string_literal: true

require_relative 'au_ps_inferno/suite/au_ps_v100'

Dir[File.join(__dir__, 'au_ps_inferno', 'generated', '*', 'suite', '*_suite.rb')].each do |f|
  require_relative f
end
