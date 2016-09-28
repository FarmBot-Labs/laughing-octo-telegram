defmodule Network.EventManager do
  use GenEvent
  require Logger

  def handle_event({:udhcpc, _pid, :bound,
    %{domain: _, ifname: "wlan0", ipv4_address: _ipaddr,
    ipv4_broadcast: _ipbc, ipv4_gateway: _ipgateway,
    ipv4_subnet_mask: _submask, nameservers: _list_of_stuff}}, state) do
      Logger.debug("WE ARE CONNECTED")
      Wifi.set_connected(true)
      {:ok,state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

end
