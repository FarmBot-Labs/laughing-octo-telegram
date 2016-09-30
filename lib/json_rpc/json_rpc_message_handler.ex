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
      handle_rpc(event)
    end
    {:noreply, [], state}
  end

  # JSON RPC RESPONSE
  def ack_msg(id) when is_bitstring(id) do
    Poison.encode!(
    %{id: id,
      error: nil,
      result: "OK"})
  end

  # JSON RPC RESPONSE ERROR
  def ack_msg(id, {name, message}) when is_bitstring(id) and is_bitstring(name) and is_bitstring(message) do
    Poison.encode!(
    %{id: id,
      error: %{name: name,
               message: message },
      result: nil})
  end

  def log_msg(message) do
    Poison.encode!(
      %{ id: nil,
         method: "log_message",
         params:[%{status: BotStatus.get_status,
                   time: :os.system_time(:seconds),
                   message: message}] })
  end

  def handle_rpc(%{"method" => method, "params" => params, "id" => id})
  when is_list(params) and
       is_bitstring(method) and
       is_bitstring(id)
  do
    case do_handle(method, params) do
      :ok -> MqttHandler.emit(ack_msg(id))
      {:error, name, message} -> MqttHandler.emit(ack_msg(id, {name, message}))
      unknown_error -> MqttHandler.emit(ack_msg(id, {"unknown_error", "#{inspect unknown_error}"}))
    end
  end

  # E STOP
  def do_handle("emergency_stop", _) do
    Command.e_stop
  end

  # Home All
  def do_handle("home_all", [ %{speed: s} ]) when is_integer s do
    Command.home_all(s)
  end

  def do_handle("home_all", [ %{speed: s} ]) when is_bitstring s do
    Command.home_all("#{s}")
  end

  def do_handle("home_all", _)  do
    {:error, "BAD_PARAMS",
      Poison.encode(%{"speed" => "number"})}
  end

  # WRITE_PIN
  def do_handle("write_pin", [ %{"pin_mode" => 1, "pin_number" => p, "pin_value" => v} ])
    when is_integer p and
         is_integer v
  do
    Command.write_pin(p,v,1)
  end

  def do_handle("write_pin", [ %{"pin_mode" => 0, "pin_number" => p, "pin_value" => v} ])
    when is_integer p and
         is_integer v
  do
    Command.write_pin(p,v,0)
  end

  def do_handle("write_pin", _) do
    {:error, "BAD_PARAMS",
      Poison.encode(%{"pin_mode" => "1 or 2", "pin_number" => "number", "pin_value" => "number"})}
  end

  # Move to a specific coord
  def do_handle("move_absolute",  [%{"speed" => s, "x" => x, "y" => y, "z" => z}])
  when is_integer(x) and
       is_integer(y) and
       is_integer(z) and
       is_integer(s)
  do
    Command.move_absolute(x,y,z,s)
  end

  def do_handle("move_absolute",  _) do
    {:error, "BAD_PARAMS",
      Poison.encode(%{"x" => "number", "y" => "number", "z" => "number", "speed" => "number"})}
  end

  # Move relative to current x position
  def do_handle("move_relative", [%{"speed" => s, "x" => move_by}])
    when is_integer(s) and
         is_integer(move_by)
  do
    Command.move_relative({:x, s, move_by})
  end

  # Move relative to current y position
  def do_handle("move_relative", [%{"speed" => s, "y" => move_by}])
    when is_integer(s) and
         is_integer(move_by)
  do
    Command.move_relative({:y, s, move_by})
  end

# Move relative to current z position
  def do_handle("move_relative", [%{"speed" => s, "z" => move_by}])
    when is_integer(s) and
         is_integer(move_by)
  do
    Command.move_relative({:z, s, move_by})
  end

  def do_handle("move_relative", _) do
    {:error, "BAD_PARAMS",
      Poison.encode(%{"x or y or z" => "number to move by", "speed" => "number"})}
  end

  # Read status
  def do_handle("read_status", _) do
    send_status
  end

  # Unhandled event. Probably not implemented if it got this far.
  def do_handle(event, params) do
    Logger.debug("[RPC_HANDLER] got valid rpc, but event is not implemented.")
    {:error, "Unhandled method", "#{inspect {event, params}}"}
  end

  def log(message) when is_bitstring(message) do
    MqttHandler.emit(log_msg(message))
  end

  def send_status do
    MqttHandler.emit(Poison.encode!(BotStatus.get_status))
  end
end
