defmodule Sequence do
  use GenServer
  require Logger
  require Kernel
  def init(_) do
    {:ok, []}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_cast({:add_step, function}, steps) do
    {:noreply, steps ++ [function]}
  end

  def handle_call({:get_steps}, _from, steps) do
    {:reply, steps, steps}
  end

  def handle_call({:clean_steps}, _from, steps) do
    {:reply, steps, []}
  end

  def handle_call({:execute}, _from, steps) do
    pid = spawn fn -> Enum.each(steps, fn step -> Kernel.apply(step, []) end) end
    {:reply, pid, []}
  end

  def execute do
    GenServer.call(__MODULE__, {:execute})
  end

  # Pattern match available commands
  def add_step(step,id \\ nil)
  def add_step(%{"command" => command, "message_type" => "move_absolute",
                "position" => _position}, id) do
    #TODO: i think this would allow negative numbers
    xpos = Map.get(command, "x", nil)
    ypos = Map.get(command, "y", nil)
    zpos = Map.get(command, "z", nil)
    speed = Map.get(command, "speed", nil)
    GenServer.cast(__MODULE__, {:add_step, fn -> Command.move_absolute(xpos,ypos,zpos,speed, id) end})
  end

  def add_step(%{"command" => %{"speed" => speed, "x" => x, "y" => y, "z" => z}, "message_type" => "move_relative", "position" => _position}, _id) do
    Logger.debug("Add Step for move_relative is not implemented")
    # GenServer.cast(__MODULE__, {:add_step, fn -> Command.move_relative() end})
  end

  # Write pin (MODE IS NOT WORKING?)
  def add_step(%{"command" => %{"mode" => _mode, "pin" => pin, "value" => value}, "message_type" => "pin_write", "position" => _position}, id) do
    GenServer.cast(__MODULE__, {:add_step, fn -> Command.write_pin(String.to_integer(pin), String.to_integer(value),0, id) end})
  end

  # Process.sleep seems to be off by a couple seconds?
  def add_step(%{"command" => %{"value" => milis}, "message_type" => "wait", "position" => _position}, _id) do
    GenServer.cast(__MODULE__, {:add_step, fn -> Process.sleep(String.to_integer(milis)) end})
  end

  # Stub af here
  def add_step(%{"command" => command, "message_type" => "read_pin", "position" => position}, _id) do
    # I dont know what this is supposed to do ???
    Logger.debug("add_step: COMMAND: #{inspect command}, POSITION: #{inspect position}")
  end

  def add_step(step, _id) do
    Logger.debug("Unable to add step: #{inspect step}")
  end

  def add_steps(steps, id) when is_list(steps) do
    Enum.each(steps, fn step -> add_step(step, id)  end)
  end

  def get_steps do
    GenServer.call(__MODULE__, {:get_steps})
  end

  def clean_steps do
    GenServer.call(__MODULE__, {:clean_steps})
  end
end
