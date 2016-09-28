defmodule BotCommandHandler do
  require Logger
  use GenServer

  @moduledoc """
    This is the log mechanism for bot commands.
  """

  def init(_args) do
    {:ok, pid} = GenEvent.start_link
    GenEvent.add_handler(pid, BotCommandManager, [])
    spawn fn -> get_events(pid) end
    {:ok, pid}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def handle_cast({:add_event, event}, pid) do
    GenEvent.notify(pid, event)
    {:noreply, pid}
  end

  def handle_call(:get_pid, _from,  pid) do
    {:reply, pid, pid}
  end

  def handle_call(:e_stop, _from, pid) do
    GenEvent.notify(pid, :e_stop)
    {:reply, :ok, pid}
  end

  def get_pid do
    GenServer.call(__MODULE__, :get_pid, 5000)
  end

  def e_stop do
    GenServer.call(__MODULE__, :e_stop, 5000)
  end

  # Gets current events.
  # acts upon them one by one
  # and gets more events
  def get_events(pid) do
    events = GenEvent.call(pid, BotCommandManager, :events)
    for event <- events do
      Process.sleep(150)
      check_busy
      BotStatus.busy true
      do_handle(event)
      # Command.log("Done executing Command log.")
    end
    get_events(pid)
  end

  defp check_busy do
    case BotStatus.busy? do
      true -> check_busy
      false -> :ok
    end
  end

  def notify(event) do
    GenServer.cast(__MODULE__, {:add_event, event})
  end

  defp do_handle({:home_x, {speed}}) do
    Logger.info("HOME X")
    SerialMessageManager.sync_notify( {:send, "F11"} )
  end

  defp do_handle({:home_y, {speed}}) do
    Logger.info("HOME Y")
    SerialMessageManager.sync_notify( {:send, "F12"} )
  end

  defp do_handle({:home_z, {speed}}) do
    Logger.info("HOME Z")
    SerialMessageManager.sync_notify( {:send, "F13"} )
  end

  # These need to be "safe" commands. IE they shouldnt crash anythin.
  defp do_handle({:write_pin, {pin, value, mode}}) do
    Logger.info("WRITE_PIN " <> "F41 P#{pin} V#{value} M#{mode}")
    SerialMessageManager.sync_notify( {:send, "F41 P#{pin} V#{value} M#{mode}"} )
  end

  defp do_handle({:move_absolute, {x,y,z,_s}}) do
    Logger.info("MOVE_ABSOLUTE " <> "G00 X#{x} Y#{y} Z#{z}")
    SerialMessageManager.sync_notify( {:send, "G00 X#{x} Y#{y} Z#{z}"} )
  end

  defp do_handle({method, params}) do
    Command.log("Unhandled method: #{inspect method} with params: #{inspect params}")
    Logger.debug("Unhandled method: #{inspect method} with params: #{inspect params}")
  end

  # Unhandled event. Probably not implemented if it got this far.
  defp do_handle(event) do
    Command.log("[Command Handler] (Probably not implemented) Unhandled Event: #{inspect event}")
    Logger.debug("[Command Handler] (Probably not implemented) Unhandled Event: #{inspect event}")
  end
end
