defmodule Network.Ethernet do

  def init([]) do
    Nerves.Networking.setup :eth0
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
end
