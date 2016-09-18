defmodule Network.Wifi do

  def init([]) do
    Nerves.InterimWiFi.setup "wlan0", ssid: "#DicksOut4Harambe", key_mgmt: :"WPA-PSK", psk: "Gizmos123"
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
end
