alias Experimental.{GenStage}
defmodule GcodeMessageHandler do
  require IEx
  use GenStage
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [SerialMessageManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      do_handle(event)
    end
    {:noreply, [], state}
  end

  # I think this is supposed to be somewhere else.
  def do_handle({:send, str}) do
    GenServer.cast(UartHandler, {:send, str})
  end

  # This is the heartbeat messge.
  def do_handle({:gcode, {:idle} }) do
    BotStatus.busy false
  end

  # The opposite of the below command?
  def do_handle({:gcode, {:done } }) do
    BotStatus.busy false
  end

  # I'm not entirely sure what this is.
  def do_handle({:gcode, {:received } }) do
    BotStatus.busy true
  end

  def do_handle({:gcode, { :report_pin_value, params }}) do
    ["P"<>pin, "V"<>value] = String.split(params, " ")
    Logger.debug("pin#{pin}: #{value}")
    BotStatus.set_pin(String.to_integer(pin), String.to_integer(value))
  end

  # TODO report end stops
  def do_handle({:gcode, {:reporting_end_stops, params }}) do
    Logger.debug("[gcode_handler] {:reporting_end_stops} stub: #{params}")
    # "XA0 XB0 YA0 YB0 ZA0 ZB0"
    stop_values = String.split(params, " ")
    # ["XA0", "XB0", "YA0", "YB0", "ZA0", "ZB0"]
    Enum.map(params, fn param -> String.split_at(param, 2) end) |>
    # [{"XA", "0"}, {"XB", "0"}, {"YA", "0"}, {"YB", "0"}, {"ZA", "0"}, {"ZB", "0"}]
    Enum.each(fn es -> BotStatus.set_end_stop(es) end)
  end

  # This needs more pattern matching. something like:
  # "X34 Y756 Z23" = "X" <> x " Y" <> y <> " Z"<>z
  def do_handle({:gcode, { :report_current_position, position }}) do
    # This is dirty as hell lol
    [x,y,z] = String.split(position, " ") |> Enum.map(fn(v) -> String.split(v, String.first(v)) end) # [["", "123"], ["", "345"], ["", "-445"]]
                                          |> Enum.map(fn(f) -> String.to_integer(List.last(f))  end) # [123, 345, -445]
    BotStatus.set_pos(x,y,z)
  end

  def do_handle({:gcode, {:report_parameter_value, param }}) do
    Logger.debug("Params: #{inspect param}")
    [p, v] = String.split(param, " ")
    [_, real_p] = String.split(p, "P")
    [_, real_v] = String.split(v, "V")
    Logger.debug("Param: #{real_p}, Value: #{real_v}")
    String.Casing.downcase(Atom.to_string(Gcode.parse_param(real_p) )) |>
    BotStatus.set_param(real_v)
  end

  # Serial sending a debug message. Print it.
  def do_handle({:gcode, {:debug_message, message}} ) do
    Logger.debug("Debug message from arduino: #{message}")
  end

  # Unhandled gcode message
  def do_handle({:gcode, {:unhandled_gcode, code}}) do
    Logger.debug("[gcode_handler] Broken code? : #{inspect code}")
  end

  # Catch all for serial messages
  def do_handle({:gcode, message}) do
    Logger.debug("[gcode_handler] Unhandled Serial Gcode: #{inspect message}")
  end
end
