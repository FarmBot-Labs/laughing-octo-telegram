defmodule Command do
  require Logger
  @moduledoc """
    false
  """

  @doc """
    EMERGENCY STOP
  """
  def e_stop(id \\ nil) do
    UartHandler.send("E")
    BotStatus.set_pos(:unknown, :unknown, :unknown)
    Command.read_status(id, "emergency_stop")
    Process.exit(Process.whereis(BotCommandHandler), :kill)
  end

  @doc """
    Home All
  """
  def home_all(speed, id \\ nil) do
    Logger.info("HOME ALL")
    # SerialMessageManager.sync_notify( {:send, "G28"} )
    Command.move_absolute(0, 0, 0, speed, id)
  end

  @doc """
    Home x
    I dont think anything uses these.
  """
  def home_x(speed,id \\ nil) do
    BotCommandHandler.notify({:home_x, speed})
    Command.read_status(id)
  end

  @doc """
    Home y
  """
  def home_y(speed,id \\ nil) do
    BotCommandHandler.notify({:home_y, speed})
    Command.read_status(id)
  end

  @doc """
    Home z
  """
  def home_z(speed,id \\ nil) do
    BotCommandHandler.notify({:home_z, speed})
    Command.read_status(id)
  end

  @doc """
    Writes a pin high or low
  """
  def write_pin(pin, value, mode \\ "1", id \\ nil)
  def write_pin(pin, value, mode, id) do
    BotStatus.set_pin(pin, value)
    Command.read_status(id, "single_command")
    BotCommandHandler.notify({:write_pin, {pin, value, mode}})
  end

  @doc """
    Moves to (x,y,z) point.
    Sets the bot status to given coords
    replies to the mqtt message that caused it (if one exists)
    adds the move to the command queue.
  """
  def move_absolute(x \\ 0,y \\ 0,z \\ 0,s \\ 100, id \\ nil)
  def move_absolute(x, y, z, s, id) when x >= 0 and y >= 0 do
    BotStatus.set_pos(x,y,z)
    Command.read_status(id, "single_command")
    BotCommandHandler.notify({:move_absolute, {x,y,z,s}})
  end

  # When both x and y are negative
  def move_absolute(x, y, z, s,id ) when x < 0 and y < 0 do
    BotStatus.set_pos(0,0,z)
    Command.read_status(id, "single_command")
    BotCommandHandler.notify({:move_absolute, {0,0,z,s}})
  end

  # when x is negative
  def move_absolute(x, y, z, s,id ) when x < 0 do
    BotStatus.set_pos(0,y,z)
    Command.read_status(id, "single_command")
    BotCommandHandler.notify({:move_absolute, {0,y,z,s}})
  end

  # when y is negative
  def move_absolute(x, y, z, s, id ) when y < 0 do
    BotStatus.set_pos(x,0,z)
    Command.read_status(id, "single_command")
    BotCommandHandler.notify({:move_absolute, {x,0,z,s}})
  end

  @doc """
    Gets the current position
    then pipes into move_absolute
  """
  def move_relative(e, id \\ nil)
  def move_relative({:x, s, move_by}, id) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x + move_by,y,z,s,id)
  end

  def move_relative({:y, s, move_by}, id) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x,y + move_by,z,s,id)
  end

  def move_relative({:z, s, move_by}, id) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x,y,z + move_by,s,id)
  end

  @doc """
    Used when bootstrapping the bot.
    Reads pins 0-13 in digital mode.
  """
  def read_all_pins do
    spawn fn -> Enum.each(0..13, fn pin -> Command.read_pin(pin); Process.sleep 500 end) end
  end

    @doc """
      Used when bootstrapping the bot.
      Reads all the params.
    """
  def read_all_params do
    rel_params = [0,11,12,13,21,22,23,
                  31,32,33,41,42,43,51,
                  52,53,61,62,63,71,72,73]
    spawn fn -> Enum.each(rel_params, fn param -> Command.read_param(param); Process.sleep(500) end ) end
  end

  @doc """
    Reads a pin value.
    mode: 1 = analog.
    mode: 0 = digital.
  """
  def read_pin(pin, mode \\ 0) do
    SerialMessageManager.sync_notify({:send, "F42 P#{pin} M#{mode}" })
  end

  @doc """
    Reads a param. Needs the integer version of said param.
  """
  def read_param(param, id \\nil) when is_integer param do
    SerialMessageManager.sync_notify({:send, "F21 P#{param}" })
    id
  end

  # I don't have this one read_status at the end because if mqtt not connected
  # it would crash on every boot, until mqtt connects and it is just ugly,
  # So i only read_status from the mqtt message handler.
  def update_param(param, value, id \\nil)
  def update_param(param, value, id) when is_integer param do
    Logger.debug(value)
    SerialMessageManager.sync_notify({:send, "F22 P#{param} V#{value}"})
    Command.read_param(param)
    id
  end

  @doc """
    This should really renamed to rpc_builder or something.
  """
  def read_status(id \\ nil, method \\ "read_status")
  def read_status(id, method) do
    current_status = BotStatus.get_status
    [x,y,z] = BotStatus.get_current_pos
    results = Map.merge(%{
      busy: 0,
      last: Map.get(current_status, :LAST),
      method: method,
      s: Map.get(current_status, :S),
      x: x,
      y: y,
      z: z}, Map.get(current_status, :PARAMS)) |> Map.merge(Map.get(current_status, :PINS))

    message = %{error: nil,
                id: id,
                result: results}
    MqttHandler.emit( Poison.encode!(message) )
  end

  @doc """
    Logs a message to the frontend
    The double posting is a problem in Frontend or Farmbot-JS
  """
  def log(message, priority \\ "low" ) when is_bitstring message do
    [x,y,z] = BotStatus.get_current_pos
    m = %{id: nil,
          result: %{ name: "log_message",
                     priority: priority,
                     data: message,
                     status: %{X: x, Y: y, Z: z},
                     time: :os.system_time(:seconds) }}
    MqttHandler.log( Poison.encode!(m) )
  end
end
