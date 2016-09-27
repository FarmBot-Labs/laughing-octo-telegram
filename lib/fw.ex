defmodule Fw do
  require Logger
  use Supervisor
  @target System.get_env("NERVES_TARGET") || "rpi3"

  def init(_args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, MyRouter, [], [port: 4000]),
      supervisor(NetworkSupervisor, [[]], restart: :permanent),
      supervisor(Controller, [[]], restart: :permanent)
    ]
    opts = [strategy: :one_for_all, name: Fw]
    supervise(children, opts)
  end

  def start(_type, args) do
    Logger.debug("Starting Firmware on Target: #{@target}")
    Supervisor.start_link(__MODULE__, args)
  end
end
