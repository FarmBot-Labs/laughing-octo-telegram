defmodule Network.Wifi do

  def init([]) do
    Nerves.InterimWiFi.setup "wlan0", ssid: "ssid", key_mgmt: :"WPA-PSK", psk: "super secret password"
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
end
