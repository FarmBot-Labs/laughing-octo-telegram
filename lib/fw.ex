defmodule Fw do
  use Application
  require Logger
  @target System.get_env("NERVES_TARGET") || "rpi3"
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.debug("Starting Firmware on Target: #{@target}")

    # Setup Network
    Nerves.Networking.setup :eth0



    children = [
      Plug.Adapters.Cowboy.child_spec(:http, MyRouter, [], [port: 4001])
    ]
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)
    Controller.start(:normal, [])
    {:ok, sup}
  end
end
