defmodule NetworkSupervisor do
  require Logger
  use Supervisor

  def start_link(_args) do
    Logger.debug("Starting Network")
    Nerves.Networking.setup(:eth0) # eh
    children = [ worker(Wifi, [[]]) ]
    opts = [strategy: :one_for_all, name: NetworkSupervisor]
    Supervisor.start_link(children, opts)
  end
end
