defmodule BotCommandHandler do
  require Logger
  use GenServer

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

  def get_events(pid) do
    event = GenEvent.call(pid, BotCommandManager, :latest_event)
    case event do
      nil -> get_events(pid)
      event -> check_busy
               do_handle(event)
               BotStatus.busy true
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
    Logger.debug("adding event")
    GenServer.cast(__MODULE__, {:add_event, event})
  end

  def do_handle({:home_all, {speed, id}}) do
    Logger.info("HOME ALL")
    # SerialMessageManager.sync_notify( {:send, "G28"} )
    Command.move_absolute(0, 0, 0, speed, id)
  end

  def do_handle({:home_x, {_speed, id}}) do
    Logger.info("HOME X")
    SerialMessageManager.sync_notify( {:send, "F11"} )
    Command.read_status(id)
  end

  def do_handle({:home_y, {_speed, id}}) do
    Logger.info("HOME Y")
    SerialMessageManager.sync_notify( {:send, "F12"} )
    Command.read_status(id)
  end

  def do_handle({:home_z, {_speed, id}}) do
    Logger.info("HOME Z")
    SerialMessageManager.sync_notify( {:send, "F13"} )
    Command.read_status(id)
  end

  def do_handle({:write_pin, {pin, value, mode, id}}) do
    Logger.info("WRITE_PIN " <> "F41 P#{pin} V#{value} M#{mode}")
    SerialMessageManager.sync_notify( {:send, "F41 P#{pin} V#{value} M#{mode}"} )
    BotStatus.set_pin(pin, value)
    Command.read_status(id, "single_command")
  end

  def do_handle({:move_absolute, {x,y,z,_s,id}}) do
    BotStatus.set_pos(x,y,z)
    Command.read_status(id, "single_command")
    Logger.info("MOVE_ABSOLUTE " <> "G00 X#{x} Y#{y} Z#{z}")
    SerialMessageManager.sync_notify( {:send, "G00 X#{x} Y#{y} Z#{z}"} )
  end

  def do_handle({method, params}) do
    Logger.debug("Unhandled method: #{inspect method} with params: #{inspect params}")
  end

  # Unhandled event. Probably not implemented if it got this far.
  def do_handle(event) do
    Logger.debug("[Command Handler] (Probably not implemented) Unhandled Event: #{inspect event}")
  end
end
