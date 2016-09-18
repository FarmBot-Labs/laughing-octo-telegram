defmodule Network.Supervisor do
  use Supervisor
  @target System.get_env("NERVES_TARGET") || "rpi2"
  def start_link() do
    opts = [strategy: :one_for_one, name: __MODULE__]
    default_children = [
      worker(Network.Ethernet, [])
    ]
    case has_wifi(@target) do
      true -> Supervisor.start_link(default_children ++ [worker(Network.Wifi, [])], opts)
      _ -> Supervisor.start_link(default_children, opts)
    end
  end

  defp has_wifi("rpi3") do
    true
  end

  defp has_wifi("rpi2") do
    false
  end
end
