alias Experimental.{GenStage}
defmodule RPCMessageHandler do
  use GenStage
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(_args) do
    {:consumer, :ok, subscribe_to: [RPCMessageManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      # I don't know why I did this looking back.
      do_handle(event)
    end
    {:noreply, [], state}
  end

  # E STOP
  def do_handle(%{"method" => "single_command.EMERGENCY STOP", "params" => _, "id" => id}) do
    Command.e_stop(id)
  end

  # Home All
  def do_handle(%{"method" =>"single_command.HOME ALL", "params" => %{"name" => "homeAll", "speed" => s}, "id" => id }) do
    Command.home_all(s, id)
  end

  # Write a pin
  def do_handle(%{"method" => "single_command.PIN WRITE", "params" => %{"mode" => m, "pin" => p, "value1" => v}, "id" => id}) do
    Command.write_pin(p,v,m, id)
  end

  # Move to a specific coord
  def do_handle(%{"method" => "single_command.MOVE ABSOLUTE", "params" =>  %{"speed" => s, "x" => x, "y" => y, "z" => z}, "id" => id}) do
    Command.move_absolute(x,y,z,s, id)
  end

  # I think this will work
  def do_handle(%{"method" => "single_command.MOVE RELATIVE", "params" =>  %{"name" => "moveRelative", "speed" => s, "x" => move_by}, "id" => id}) do
    Command.move_relative({:x, s, move_by}, id)
  end

  def do_handle(%{"method" => "single_command.MOVE RELATIVE", "params" => %{"name" => "moveRelative", "speed" => s, "y" => move_by}, "id" => id}) do
    Command.move_relative({:y, s, move_by}, id)
  end

  def do_handle(%{"method" => "single_command.MOVE RELATIVE", "params" => %{"name" => "moveRelative", "speed" => s, "z" => move_by}, "id" => id}) do
    Command.move_relative({:z, s, move_by}, id)
  end

  # Read status
  def do_handle(%{"method" => "read_status", "id" => id}) do
    Command.read_status(id)
  end

  # Im getting tired, and can't tell the difference between these functions?
  def do_handle(%{"id" => id,
                  "method" => "exec_sequence",
                  "params" => %{"color" => color,
                                "id" => _param_id,
                                "name" => name,
                                "steps" => steps }}) do

    Logger.debug("Execute sequence: #{id}, #{name}, #{color}")
    SequenceManager.sync_notify({:exec_sequence, steps, id})
  end


  def do_handle(%{"id" => id,
                  "method" => "exec_sequence",
                  "params" => %{"color" => color,
                                "dirty" => _dirty,
                                "name" => name,
                                "steps" => steps }}) do

    Logger.debug("Execute sequence: #{id}, #{name}, #{color}")
    SequenceManager.sync_notify({:exec_sequence, steps, id})
  end

  # ALLOW NEGATIVES (Juset realized i probs dont need this to be three seperate things)
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_home_up_x" => value}}) do
    Logger.debug("update_calibration: movement_home_up_x: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_home_up_x") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_home_up_y" => value}}) do
    Logger.debug("update_calibration: movement_home_up_y: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_home_up_y") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_home_up_z" => value}}) do
    Logger.debug("update_calibration: movement_home_up_z: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_home_up_z") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end


  # INVERT MOTORS
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_invert_motor_x" => value}}) do
    Logger.debug("update_calibration: movement_invert_motor_x: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_invert_motor_x") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_invert_motor_y" => value}}) do
    Logger.debug("update_calibration: movement_invert_motor_y: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_invert_motor_y") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_invert_motor_z" => value}}) do
    Logger.debug("update_calibration: movement_invert_motor_z: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_invert_motor_z") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end

  # INVERT ENDPOINTS
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_invert_endpoints_x" => value}}) do
    Logger.debug("update_calibration: movement_invert_motor_x: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_invert_motor_x") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_invert_endpoints_y" => value}}) do
    Logger.debug("update_calibration: movement_invert_motor_y: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_invert_motor_y") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end
  def do_handle(%{"id" => id, "method" => "update_calibration", "params" => %{"movement_invert_endpoints_z" => value}}) do
    Logger.debug("update_calibration: movement_invert_motor_z: #{value}")
    Command.update_param(Gcode.parse_param(String.Casing.upcase("movement_invert_motor_z") |> String.to_atom),
        value, id) |> Command.read_status("calibrate_axis") end

  def do_handle(%{"id" => _id, "method" => "sync_sequence", "params" => _params}) do
    BotSync.sync
    Command.read_status("sync_sequence")
  end

  # Unhandled event. Probably not implemented if it got this far.
  def do_handle(event) do
    Command.log("Unhandled JSON RPC EVENT: #{inspect event}")
    Logger.debug("[RPC_HANDLER] (Probably not implemented) Unhandled Event: #{inspect event}")
  end
end
