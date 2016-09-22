defmodule Fw do
  require Logger
  @target System.get_env("NERVES_TARGET") || "rpi3"
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.debug("Starting Firmware on Target: #{@target}")
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, MyRouter, [], [port: 4000]),
      supervisor(NetworkSupervisor, [[]], restart: :permanent),
      supervisor(Controller, [[]], restart: :permanent)
    ]
    opts = [strategy: :one_for_all, name: Fw]
    Supervisor.start_link(children, opts)
  end
end
