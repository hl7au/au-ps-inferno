module AUPSTestKit
  class BasicTest < Inferno::Test
    def show_message(message, state_value)
      if state_value
        info message
      else
        warning message
      end
    end

    def execute_statistics(json_data, json_path_expression, message_base, humanized_name)
      data_value = JsonPath.on(json_data, json_path_expression).first.present?
      show_message("#{message_base}: #{humanized_name}: #{data_value}", data_value)
    end
  end
end