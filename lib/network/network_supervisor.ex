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

  def set_time do
    System.cmd("ntpd", ["-q", "-p", "pool.ntp.org"])
    check_time_set
  end

  def check_time_set do
    if :os.system_time(:seconds) <  1474929 do
      check_time_set # wait until time is set
    end
  end
end
