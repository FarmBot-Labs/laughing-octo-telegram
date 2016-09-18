alias Experimental.{GenStage}
defmodule CommandMessageHandler do
  @uuid Application.get_env(:mqtt, :uuid)
  require IEx
  use GenStage
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # Bootstarp the bot here.
    spawn fn -> Enum.each(0..13, fn pin -> Command.read_pin(pin); Process.sleep 500 end) end
    {:consumer, :ok, subscribe_to: [CommandMessageManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      do_handle(event)
    end
    {:noreply, [], state}
  end

  # E STOP
  def do_handle(%{"method" => "single_command.EMERGENCY STOP", "params" => _, "id" => id}) do
    Command.e_stop(id)
  end

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

  def do_handle(%{"id" => _id, "method" => "sync_sequence", "params" => _params}) do
    Logger.debug("sync_sequence request. I don't know what this message is for?")
  end

  # Unhandled event. Probably not implemented if it got this far.
  def do_handle(event) do
    Logger.debug("[command_handler] (Probably not implemented) Unhandled Event: #{inspect event}")
  end
end
