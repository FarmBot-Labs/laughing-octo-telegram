defmodule Fw do
  use Application
  require Logger
  @target System.get_env("NERVES_TARGET") || "rpi2"
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.debug("TARGET: #{@target}")
    children = [
      supervisor(Network.Supervisor, [])
    ]
    opts = [strategy: :one_for_one, name: Fw.Supervisor]

    # Im so sorry i keep doing this
    {:ok, sup} = Supervisor.start_link(children, opts)
    Controller.start(:normal, [])
    Bus.start(:normal,[])
    {:ok, sup}
  end
end
