defmodule BotStatus do
  use GenServer
  require Logger
  def init(_) do
    initial_status = %{X: 0, Y: 0, Z: 0, S: 10,
                       VERSION: Fw.version,
                       BUSY: true, LAST: "",
                       PINS: Map.new,
                       PARAMS: %{ movement_axis_nr_steps_x: 222,
                                  movement_axis_nr_steps_y: 222,
                                  movement_axis_nr_steps_z: 222,
                                  param_version: "alpha" } }
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
    {:reply, Map.get(current_status, :BUSY), current_status}
  end

  def handle_call(:get_controller_version, _from, current_status) do
    {:reply, Map.get(current_status, :VERSION), current_status }
  end

  def handle_call({:get_pin, pin}, _from, status) do
    all_pins = Map.get(status, :PINS)
    got_pin = Map.get(all_pins, "pin#{pin}")
    {:reply, got_pin, status}
  end

  def handle_cast({:set_pin, pin, value}, current_status)  do
    current_pin_status = Map.get(current_status, :PINS)
    new_pin_status = Map.put(current_pin_status, pin, value)
    {:noreply, Map.update(current_status, :PINS, new_pin_status, fn _x -> new_pin_status end)}
  end

  def handle_cast({:set_param, param, value}, current_status) do
    current_params = Map.get(current_status, :PARAMS)
    new_params = Map.put(current_params, param, value)
    {:noreply, Map.update(current_status, :PARAMS, new_params, fn _x -> new_params end)}
  end

  def handle_cast({:set_busy, b}, current_status ) when is_boolean b do
      # if b != Map.get(current_status, :BUSY) do Logger.debug("busy: #{inspect b}") end
    {:noreply, Map.update(current_status, :BUSY, b, fn _x ->  b end)}
  end

  def handle_cast({:set_last, last}, current_status) do
    {:noreply,Map.update(current_status, :LAST, "", fn _x -> last end) }
  end

  def handle_cast({:set_pos, x,y,z}, current_status) do
    new_status = Map.update(current_status, :X, 0, fn _x -> x end) |>
                 Map.update(:Y, 0, fn _y -> y end) |>
                 Map.update(:Z, 0, fn _z -> z end)
   {:noreply,new_status}
  end

  def handle_cast({:set_end_stop, _stop, _value}, current_status) do
    #TODO: this?
    # Logger.debug("EndStop reporting is TODO")
    {:noreply,  current_status}
  end

  # Sets the pin value in the bot's status
  def set_pin(pin, value) when is_integer pin do
    case value do
      0 -> GenServer.cast(__MODULE__, {:set_pin, "pin"<>Integer.to_string(pin), :off})
      _ -> GenServer.cast(__MODULE__, {:set_pin, "pin"<>Integer.to_string(pin), :on})
    end
  end

  def set_param(param, value) when is_bitstring param do
    GenServer.cast(__MODULE__, {:set_pin, param, value})
  end

  # Gets the pin value from the bot's status
  def get_pin(pin) when is_integer pin do
    GenServer.call(__MODULE__, {:get_pin, pin})
  end

  # Sets busy to true or false.
  def busy(b) when is_boolean b do
    GenServer.cast(__MODULE__, {:set_busy, b})
  end

  # Gets busy
  def busy? do
    GenServer.call(__MODULE__, {:get_busy})
  end

  def set_last(last) do
    GenServer.cast(__MODULE__, {:set_last, last })
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
    set_pos(x,y,z )
  end

  def set_pos({:y, y}) when is_integer(y) do
    [x,_y,z] = get_current_pos
    set_pos(x,y,z)
  end

  def set_pos({:z, z}) when is_integer(z) do
    [x,y,_z] = get_current_pos
    set_pos(x,y,z )
  end

  def set_end_stop({stop, value}) do
    #TODO
    GenServer.cast(__MODULE__, {:set_end_stop, stop, value})
  end

  # Get current coords
  def get_current_pos do
    [:X,:Y,:Z] |> Enum.map(fn(v) ->  Map.get(get_status, v) end)
  end

  def get_current_version do
    GenServer.call(__MODULE__, :get_controller_version)
  end
end
