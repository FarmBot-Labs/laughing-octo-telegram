defmodule Command do
  require Logger
  @moduledoc """
    Big pattern matches r big
  """

  @doc """
    EMERGENCY STOP
  """
  def e_stop(id \\ nil) do
    Logger.info("E STOP")
    UartHandler.send("E") # Don't queue this one- write to serial line.
    BotStatus.set_last(:emergency_stop)
    read_status(id)
  end

  @doc """
    Home All
  """
  def home_all(_speed, id \\ nil) do
    Logger.info("HOME ALL")
    BotStatus.set_pos(0,0,0) # I don't know if im supposed to do this?
    SerialMessageManager.sync_notify( {:send, "G28"} )
    read_status(id)
  end

  @doc """
    Home x
  """
  def home_x(_speed,id \\ nil) do
    Logger.info("HOME X")
    SerialMessageManager.sync_notify( {:send, "F11"} )
    read_status(id)
  end

  @doc """
    Home y
  """
  def home_y(_speed,id \\ nil) do
    Logger.info("HOME Y")
    SerialMessageManager.sync_notify( {:send, "F12"} )
    read_status(id)
  end

  @doc """
    Home z
  """
  def home_z(_speed,id \\ nil) do
    Logger.info("HOME Z")
    SerialMessageManager.sync_notify( {:send, "F13"} )
    read_status(id)
  end

  @doc """
    Writes a pin high or low
  """
  def write_pin(pin, value, mode \\ "1", id \\ nil)
  def write_pin(pin, value, mode, id) do
    Logger.info("WRITE_PIN " <> "F41 P#{pin} V#{value} M#{mode}")
    SerialMessageManager.sync_notify( {:send, "F41 P#{pin} V#{value} M#{mode}"} )
    BotStatus.set_pin(pin, value)
    read_status(id)
  end

  @doc """
    Moves to (x,y,z) point
  """
  def move_absolute(x \\ 0,y \\ 0,z \\ 0,s \\ 100, id \\ nil)
  def move_absolute(x, y, z, _s, id) when x >= 0 and y >= 0 do
    Logger.info("MOVE_ABSOLUTE " <> "G00 X#{x} Y#{y} Z#{z}")
    SerialMessageManager.sync_notify( {:send, "G00 X#{x} Y#{y} Z#{z}"} )
    BotStatus.set_pos(x,y,z)
    read_status(id)
  end

  # When both x and y are negative
  def move_absolute(x, y, z, s,id ) when x < 0 and y < 0 do
    move_absolute(0,0,z,s)
    read_status(id)
  end

  # when x is negative
  def move_absolute(x, y, z, s,id ) when x < 0 do
    move_absolute(0,y,z,s)
    read_status(id)
  end

  # when y is negative
  def move_absolute(x, y, z, s, id ) when y < 0 do
    move_absolute(x,0,z,s)
    read_status(id)
  end

  def move_relative(e, id \\ nil)
  def move_relative({:x, speed, move_by}, id) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x + move_by, y,z, speed, id)
  end

  def move_relative({:y, speed, move_by}, id) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x, y + move_by ,z, speed, id)
  end

  def move_relative({:z, speed, move_by}, id) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x, y, z + move_by, speed, id)
  end

  def read_pin(pin, mode \\ 1) do
    SerialMessageManager.sync_notify( {:send, "F42 P#{pin} M#{mode}" })
  end

  def read_status(id \\ nil) do
    current_status = BotStatus.get_status
    [x,y,z] = BotStatus.get_current_pos
    results = Map.merge(%{
      busy: 0,
      last: Map.get(current_status, :LAST),
      method: "read_status",
      s: Map.get(current_status, :S),
      x: x,
      y: y,
      z: z}, Map.get(current_status, :PARAMS)) |> Map.merge(Map.get(current_status, :PINS))

    message = %{id: id,
                error: nil,
                result: results}
    MqttMessageManager.sync_notify( {:emit, Poison.encode!(message)} )
  end

  # TODO: NOT WORKING
  def boot_strap(id \\ nil) do
    message = %{id: id,
                error: nil,
                result: %{}}
    MqttMessageManager.sync_notify( {:emit, Poison.encode!(message)} )
  end
end
