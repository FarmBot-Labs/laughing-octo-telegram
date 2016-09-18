defmodule Gcode do
  @moduledoc """
    Im lazy and didn't want to parse yaml or write macros
  """

  def parse_code("G0") do  { :move_to_location_at_given_speed_for_axis } end
  def parse_code("G1" )do  { :move_to_location_on_a_straight_line } end
  def parse_code("G28") do { :move_home_all_axis } end
  def parse_code("F1" ) do { :dose_amount_of_water_using_time_in_millisecond } end
  def parse_code("F2" ) do { :dose_amount_of_water_using_flow_meter_that_measures_pulses } end
  def parse_code("F11") do { :home_x_axis } end
  def parse_code("F12") do { :home_y_axis } end
  def parse_code("F13") do { :home_z_axis } end
  def parse_code("F14") do { :calibrate_x_axis } end
  def parse_code("F15") do { :calibrate_y_axis } end
  def parse_code("F16") do { :calibrate_z_axis } end
  def parse_code("F21") do { :read_parameter } end
  def parse_code("F22") do { :write_parameter } end
  def parse_code("F23") do { :update_parameter_during_calibration } end
  def parse_code("F31") do { :read_status } end
  def parse_code("F32") do { :write_status } end
  def parse_code("F41") do { :set_a_value_on_an_arduino_pin } end
  def parse_code("F42") do { :read_a_value_from_an_arduino_pin } end
  def parse_code("F43") do { :set_the_mode_of_a_pin_in_arduino } end
  def parse_code("F44") do { :set_the_value_v_on_an_arduino_pin } end
  def parse_code("F51") do { :set_a_value_on_the_tool_mount_with_i2c } end
  def parse_code("F52") do { :read_value_from_the_tool_mount_with_i2c } end
  def parse_code("F61") do { :set_the_servo_on_the_pin_to_the_requested_angle } end
  def parse_code("F81") do { :report_end_stop } end
  def parse_code("F82") do { :report_current_position } end
  def parse_code("F83") do { :report_software_version } end
  def parse_code("E"  ) do { :emergency_stop } end
  def parse_code("R0" ) do { :idle } end
  def parse_code("R1" ) do { :received } end
  def parse_code("R2" ) do { :done } end
  def parse_code("R3" ) do { :error } end
  def parse_code("R4" ) do { :busy } end
  def parse_code("R00") do { :idle } end
  def parse_code("R01") do { :received } end
  def parse_code("R02") do { :done } end
  def parse_code("R03") do { :error } end
  def parse_code("R04") do { :busy } end
  def parse_code("R21") do { :report_parameter_value } end
  def parse_code("R31") do { :report_status_value } end
  def parse_code("R41 " <> params) do { :report_pin_value, params } end
  def parse_code("R81 " <> params ) do { :reporting_end_stops, params } end
  def parse_code("R82 " <> position) do { :report_current_position, position } end
  def parse_code("R83") do { :report_software_version } end
  def parse_code("R99" <> message) do { :debug_message, message } end
  def parse_code(code)  do {:unhandled_gcode, code} end
end
