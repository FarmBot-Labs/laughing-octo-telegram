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

  def get_pid do
    GenServer.call(__MODULE__, :get_pid, 5000)
  end

  # Gets one event at a time
  # acts upon it
  # and gets more events
  def get_events(pid) do
    case GenEvent.call(pid, BotCommandManager, :latest_event) do
      nil -> get_events(pid)
      event ->
        Process.sleep(150)
        check_busy
        BotStatus.busy true
        do_handle(event)
        get_events(pid)
    end
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

  # These need to be "safe" commands. IE they shouldnt crash anythin.
  defp do_handle({:write_pin, {pin, value, mode, id}}) do
    Logger.info("WRITE_PIN " <> "F41 P#{pin} V#{value} M#{mode}")
    SerialMessageManager.sync_notify( {:send, "F41 P#{pin} V#{value} M#{mode}"} )
  end

  defp do_handle({:move_absolute, {x,y,z,_s}}) do
    Logger.info("MOVE_ABSOLUTE " <> "G00 X#{x} Y#{y} Z#{z}")
    SerialMessageManager.sync_notify( {:send, "G00 X#{x} Y#{y} Z#{z}"} )
  end

  defp do_handle({method, params}) do
    Logger.debug("Unhandled method: #{inspect method} with params: #{inspect params}")
  end

  # Unhandled event. Probably not implemented if it got this far.
  defp do_handle(event) do
    Logger.debug("[Command Handler] (Probably not implemented) Unhandled Event: #{inspect event}")
  end
end