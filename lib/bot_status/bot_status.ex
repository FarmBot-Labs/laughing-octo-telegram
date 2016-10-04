defmodule BotStatus do
  use GenServer
  require Logger
  def init(_) do
    # MAKE SURE THE STATUS STAYS FLAT. YOU WILL THANK YOURSELF LATER.
    initial_status = %{ x: 0,y: 0,z: 0,speed: 10,
                        version: Fw.version,
                        busy: true,
                        last_sync: -1,
                        movement_axis_nr_steps_x: 222,
                        movement_axis_nr_steps_y: 222,
                        movement_axis_nr_steps_z: 222 }
    { :ok, initial_status }
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_status do
    GenServer.call(__MODULE__, {:get_status}, 90000)
  end

  def handle_call({:get_status}, _from, current_status) do
    {:reply, current_status, current_status}
  end

  def handle_call({:get_busy}, _from, current_status )  do
    {:reply, current_status.busy, current_status}
  end

  def handle_call(:get_controller_version, _from, current_status) do
    {:reply, current_status.version, current_status }
  end

  def handle_call({:get_pin, pin}, _from, current_status) when is_bitstring(pin) do
    pin = Map.get(current_status, "pin"<>pin, -1)
    {:reply, pin, current_status}
  end

  def handle_cast({:set_pin, pin, value}, current_status) when is_bitstring(pin) and is_integer(value) do
    {:noreply, Map.put(current_status, "pin"<>pin, value)}
  end

  def handle_cast({:set_param, param, value}, current_status)
    when is_bitstring(param) and
         is_integer(value)
    do
    {:noreply, Map.put(current_status, param, value)}
  end

  def handle_cast({:set_busy, b}, current_status ) when is_boolean b do
    {:noreply, Map.put(current_status, :busy, b)}
  end

  def handle_cast({:set_pos, x,y,z}, current_status)
  when is_integer x and
       is_integer y and
       is_integer z do
   new_status = Map.put(current_status, :x, x)
   |> Map.put(:y, y)
   |> Map.put(:z, z)
   {:noreply, new_status}
  end

  def handle_cast({:set_end_stop, _stop, _value}, current_status) do
    #TODO: this?
    # Logger.debug("EndStop reporting is TODO")
    {:noreply,  current_status}
  end

  # Sets the pin value in the bot's status
  def set_pin(pin, value) when is_integer pin and is_integer value do
    GenServer.cast(__MODULE__, {:set_pin, Integer.to_string(pin), value})
  end

  def set_param(param, value) when is_bitstring(param)
                                   and is_integer(value) do
    GenServer.cast(__MODULE__, {:set_param, param, value})
  end

  def set_param(param, value) when is_bitstring(param) 
                                   and is_bitstring(value) do
    set_param(param, String.to_integer(value))
  end

  # Gets the pin value from the bot's status
  def get_pin(pin) when is_integer pin do
    GenServer.call(__MODULE__, {:get_pin, Integer.to_string(pin)})
  end

  # Sets busy to true or false.
  def busy(b) when is_boolean b do
    GenServer.cast(__MODULE__, {:set_busy, b})
  end

  # Gets busy
  def busy? do
    GenServer.call(__MODULE__, {:get_busy})
  end

  # All three coords
  def set_pos(x,y,z)
  when is_integer x and
   is_integer y and
   is_integer z
  do
    GenServer.cast(__MODULE__, {:set_pos, x,y,z})
  end

  # If we only have one coord, get the current pos of the others first.
  def set_pos({:x, x}) when is_integer(x) do
    [_x,y,z] = get_current_pos
    set_pos(x,y,z)
  end

  def set_pos({:y, y}) when is_integer(y) do
    [x,_y,z] = get_current_pos
    set_pos(x,y,z)
  end

  def set_pos({:z, z}) when is_integer(z) do
    [x,y,_z] = get_current_pos
    set_pos(x,y,z)
  end

  def set_end_stop({stop, value}) do
    #TODO
    GenServer.cast(__MODULE__, {:set_end_stop, stop, value})
  end

  # Get current coords
  def get_current_pos do
    Enum.map([:x,:y,:z], fn(coord) ->
      Map.get(get_status, coord)
    end)
  end

  def get_current_version do
    GenServer.call(__MODULE__, :get_controller_version)
  end

  @doc """
    Gets the current value of a param
  """
  def get_param(param) when is_integer(param) do
    cur_status = BotStatus.get_status
    this_param = Gcode.parse_param(param) |> Atom.to_string |> String.Casing.downcase
    Map.get(cur_status, this_param)
  end
end
