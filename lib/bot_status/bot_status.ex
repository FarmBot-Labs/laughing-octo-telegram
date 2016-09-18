defmodule BotStatus do
  use GenServer
  require Logger
  def init(_) do
    initial_status = %{X: 0, Y: 0, Z: 0, S: 10, BUSY: true, LAST: "", PINS: Map.new, PARAMS: Map.new }
    { :ok, initial_status }
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_status do
    GenServer.call(__MODULE__, {:get_status})
  end

  def handle_call({:get_status}, _from, status) do
    {:reply, status, status}
  end

  def handle_call({:get_pin, pin}, _from, status) do
    all_pins = Map.get(status, :PIN)
    got_pin = Map.get(all_pins, pin)
    {:reply, got_pin, status}
  end

  def handle_cast({:set_pin, pin, value}, current_status)  do
    current_pin_status = Map.get(current_status, :PINS)
    new_pin_status = Map.put(current_pin_status, pin, value)
    {:noreply, Map.update(current_status, :PINS, new_pin_status, fn _x -> new_pin_status end)}
  end

  def handle_cast({:set_busy, b}, current_status ) when is_boolean b do
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

  # Sets the pin value in the bot's status
  def set_pin(pin, value) when is_integer pin do
    case value do
      0 -> GenServer.cast(__MODULE__, {:set_pin, "pin"<>Integer.to_string(pin), :off})
      _ -> GenServer.cast(__MODULE__, {:set_pin, "pin"<>Integer.to_string(pin), :on})
    end
  end

  # Gets the pin value from the bot's status
  def get_pin(pin) when is_integer pin do
    GenServer.call(__MODULE__, {:get_pin, pin})
  end

  def busy(b) when is_boolean b do
    GenServer.cast(__MODULE__, {:set_busy, b})
  end

  def set_last(last) do
    GenServer.cast(__MODULE__, {:set_last, last })
  end

  # All three coords
  def set_pos(x,y,z) do
    GenServer.cast(__MODULE__, {:set_pos, x,y,z})
  end

  # If we only have one coord, get the current pos of the others first.
  def set_pos({:x, x}) do
    [_x,y,z] = get_current_pos
    set_pos(x,y,z )
  end

  def set_pos({:y, y}) do
    [x,_y,z] = get_current_pos
    set_pos(x,y,z )
  end

  def set_pos({:z, z}) do
    [x,y,_z] = get_current_pos
    set_pos(x,y,z )
  end

  # Get current coords
  def get_current_pos do
    [:X,:Y,:Z] |> Enum.map(fn(v) ->  Map.get(get_status, v) end)
  end

  def get_params do
    %{  movement_axis_nr_steps_x: 222,
        movement_axis_nr_steps_y: 222,
        movement_axis_nr_steps_z: 222,
        movement_home_up_x: 0,
        movement_home_up_y: 0,
        movement_home_up_z: 1,
        movement_invert_endpoints_x: 0,
        movement_invert_endpoints_y: 0,
        movement_invert_endpoints_z: 0,
        movement_invert_motor_x: 0,
        movement_invert_motor_y: 0,
        movement_invert_motor_z: 0,
        movement_max_spd_x: 1500,
        movement_max_spd_y: 1500,
        movement_max_spd_z: 1500,
        movement_min_spd_x: 50,
        movement_min_spd_y: 50,
        movement_min_spd_z: 50,
        movement_steps_acc_dec_x: 500,
        movement_steps_acc_dec_y: 500,
        movement_steps_acc_dec_z: 500,
        movement_timeout_x: 30,
        movement_timeout_y: 30,
        movement_timeout_z: 30,
        param_version: 0 }
  end
end
